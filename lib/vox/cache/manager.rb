# frozen_string_literal: true

# frozen_string_literal: true

require 'vox/cache/memory'

module Vox
  module Cache
    class Manager
      attr_accessor :default

      def initialize(default: Memory, **options, &block)
        @caches = options
        yield(self)
      end

      def get(cache, key)
        cache_or_default(cache)

        @caches[cache].get(key)
      end

      def set(cache, key, value)
        cache_or_default(cache)

        @caches[cache].set(key, value)
      end
      
      private

      def cache_or_default(cache)
        if @default_cache.respond_to?(:call)
          @caches[cache] ||= @default.call(cache)
        else
          @caches[cache] ||= @default.new(cache)
        end
      end
    end
  end
end