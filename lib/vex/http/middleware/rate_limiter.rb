# frozen_string_literal: true

module Vex
  module HTTP
    # @!visibility private
    # A bucket used for HTTP rate limiting
    class Bucket
      # @!attribute [r] limit
      # @return [Integer]
      attr_reader :limit

      # @!attribute [r] remaining
      # @return [Integer]
      attr_reader :remaining

      # @!attribute [r] reset_time
      # @return [Time]
      attr_reader :reset_time

      def initialize(limit, remaining, reset_time)
        update(limit, remaining, reset_time)

        @mutex = Mutex.new
      end

      # @param limit [Integer]
      # @param remaining [Integer]
      # @param reset_time [Time]
      def update(limit, remaining, reset_time)
        @limit = limit
        @remaining = remaining
        @reset_time = reset_time
      end

      # @return [true, false]
      def will_limit?
        (@remaining - 1).negative? && Time.now <= @reset_time
      end

      # Lock and unlock this mutex (prevents access during reset)
      def wait_until_available
        return unless locked?

        @mutex.synchronize {}
      end

      # Lock the mutex for a given duration. Used for cooldown periods
      def lock_for(duration)
        @mutex.synchronize { sleep duration }
      end

      # Lock the mutex until the bucket resets
      def lock_until_reset
        time_remaining = @reset_time - Time.now

        raise 'Cannot sleep for negative duration.' if time_remaining.negative?

        lock_for(time_remaining) unless locked?
      end

      # @return [true, false]
      def locked?
        @mutex.locked?
      end
    end

    # @!visibility private
    # A rate limiting class used for our {Client}
    class LimitTable
      def initialize
        @bucket_key_map = {}
        @bucket_id_map = {}
        @key_to_id = {}
      end

      # Index a bucket based on the route key
      def get_from_key(key)
        @bucket_key_map[key]
      end

      # Index a bucket based on server side bucket id
      def get_from_id(id)
        @bucket_id_map[id]
      end

      # Get a bucket from a rl_key if it exists
      def id_from_key(key)
        @key_to_id[key]
      end

      # Update a rate limit bucket from response headers
      def update_from_headers(key, headers, req_id = nil)
        limit = headers['x-ratelimit-limit']&.to_i
        remaining = headers['x-ratelimit-remaining']&.to_i
        bucket_id = headers['x-ratelimit-bucket']
        reset_after = headers['x-ratelimit-reset-after']&.to_f
        retry_after = headers['retry-after']&.to_f

        if limit && remaining && reset_after && bucket_id
          reset = if retry_after
                    retry_after / 1000
                  else
                    reset_after
                  end
          update(key, bucket_id, limit, remaining, Time.now + reset)
        elsif retry_after
          update(key, bucket_id, 0, 0, Time.now + (retry_after / 1000))
        else
          LOGGER.debug { "{#{req_id}} Unable to set RL for #{key}" }
        end
      end

      # Update a rate limit bucket
      def update(key, bucket_id, limit, remaining, reset_time)
        bucket = @bucket_id_map[bucket_id]
        if bucket
          bucket.update(limit, remaining, reset_time)
          @bucket_key_map[key] = bucket_id
        else
          bucket = Bucket.new(limit, remaining, reset_time)
          @bucket_key_map[key] = bucket
          if bucket_id
            @bucket_id_map[bucket_id] = bucket
            @key_to_id[key] = bucket_id
          end
        end
      end

      # @!visibility private
      LOGGER = Logging.logger[self]
    end

    module Middleware
      # Faraday middleware to handle ratelimiting based on
      # bucket ids and the rate limit key provided by {Client#request}
      # in the request context
      class RateLimiter < Faraday::Middleware
        def initialize(app, **_options)
          super(app)
          @limit_table = LimitTable.new
          @mutex_table = Hash.new { |hash, key| hash[key] = Mutex.new }
        end

        # Request handler
        def call(env)
          rl_key = env.request.context[:rl_key]
          req_id = env.request.context[:trace]
          mutex = @mutex_table[rl_key]

          mutex.synchronize do
            rl_wait(rl_key, req_id)
            rl_wait(:global, req_id)
            @app.call(env).on_complete do |environ|
              on_complete(environ, req_id)
            end
          end
        end

        # Handler for response data
        def on_complete(env, req_id)
          resp = env.response

          if resp.status == 429 && resp.headers['x-ratelimit-global']
            @limit_table.update_from_headers(:global, resp.headers, req_id)
            Thread.new { @limit_table.get_from_key(:global).lock_until_reset }
            LOGGER.error { "{#{req_id}}} Global ratelimit hit" }
          end

          update_from_headers(env)
        end

        private

        # Lock a rate limit mutex preemptively if the next request would deplete the bucket.
        def rl_wait(key, trace)
          bucket_id = @limit_table.id_from_key(key)
          bucket = if bucket_id
                     @limit_table.get_from_id(bucket_id)
                   else
                     @limit_table.get_from_key(key)
                   end
          return if bucket.nil?

          bucket.wait_until_available
          return unless bucket.will_limit?

          LOGGER.info do
            duration = bucket.reset_time - Time.now
            "{#{trace}} [RL] Locking #{key} for #{duration.truncate(3)} seconds"
          end

          bucket.lock_until_reset
        end

        def update_from_headers(env)
          rl_key = env.request.context[:rl_key]
          req_id = env.request.context[:trace]
          @limit_table.update_from_headers(rl_key, env.response.headers, req_id)
        end

        # @!visibility private
        LOGGER = Logging.logger[Vex::HTTP]
      end
    end
  end
end
