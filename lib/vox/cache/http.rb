# frozen_string_literal: true

require 'vox/http/client'
require 'vox/cache/memory'

module Vox
  module Cache
    class HTTP < Memory
      def initialize(key, http)
        @key = key
        @http = http
        @fetch_method = :"get_#{key}"
        super(key)
      end

      def get(id)
        @data[id] ||= fetch(id)
      end

      def fetch(id)
        @http.__send__(@fetch_method, id)
      end
    end
  end
end
