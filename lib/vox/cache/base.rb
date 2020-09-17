# frozen_string_literal: true

module Vox
  module Cache
    # Noop cache that only provides interface methods
    class Base
      def get(key)
      end

      def set(key, value)
      end

      def delete(key)
      end
    end
  end
end
