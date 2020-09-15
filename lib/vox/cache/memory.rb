# frozen_string_literal: true

require 'vox/cache/base'

module Vox
  module Cache
    class Memory < Base
      def initialize(_key)
        @data = {}
      end

      def get(key)
        @data[key]
      end

      def get?(key)
        @data[key]
      end

      def set(key, value)
        @data[key, value]
      end
    end
  end
end
