# frozen_string_literal: true

require 'vox/cache/http'

module Vox
  module Cache
    class Redis < Base
      def initialize(key, redis)
        @redis = redis
        super(key, http)
      end

      def get(id)
        MultiJson.load(@redis.get("#{@key}:#{id}"))
      end

      def get?(id)
        get(id)
      end

      def set(id, data)
        @redis.set("#{@key}:#{id}", MultiJson.dump(data))
      end
    end
  end
end
