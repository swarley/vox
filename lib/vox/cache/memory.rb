# frozen_string_literal: true

require 'vox/cache/base'

module Vox
  module Cache
    class Memory < Base
      def initialize
        @data = {}
      end

      def get(key)
        @data[key]
      end

      def set(key, value)
        @data[key] = value
      end

      def delete(key)
        @data.delete(key)
      end
    end
  end
end
