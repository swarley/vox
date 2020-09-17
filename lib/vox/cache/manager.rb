# frozen_string_literal: true

# frozen_string_literal: true

require 'vox/cache/memory'

module Vox
  module Cache
    class Manager
      attr_accessor :default

      def initialize(default: Memory, **options)
        @caches = options
        @default = default
        yield(self) if block_given?
      end

      def get(cache, key, &block)
        cache_or_default(cache)

        @caches[cache].get(key, &block)
      end

      def set(cache, key, value)
        cache_or_default(cache)

        @caches[cache].set(key, value)
      end

      def [](name)
        @caches[name] ||= cache_or_default(name)
      end

      def delete(cache, key)
        cache_or_default(cache)

        @caches[cache].delete(key)
      end
      
      private

      def cache_or_default(cache)
        if @default_cache.respond_to?(:call)
          @caches[cache] ||= @default.call
        else
          @caches[cache] ||= @default.new
        end
      end
    end
  end
end