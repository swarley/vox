# frozen_string_literal: true

require 'vox/cache/http'

module Vox
  module Cache
    class Redis < HTTP
      def initialize(key, http, redis)
        @redis = redis
        super(key, http)
      end

      def get?(id)
        @redis.get("#{@key}:#{id}")
      end

      def set(id, data)
        @redis.set("#{@key}:#{id}", MultiJson.dump(data))
      end

      def fetch(id)
        data = @redis.get("#{@key}:#{id}")
        return MultiJson.load(data, symbolize_keys: true) if data
        
        data = super
        set(id, data)

        data
      end
    end
  end
end
