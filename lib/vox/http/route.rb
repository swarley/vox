# frozen_string_literal: true

module Vox
  module HTTP
    # Route that contains information about a request path, intended
    # for use with {HTTP::Client#request}.
    class Route
      # Major parameters that are significant when forming a rate limit key.
      MAJOR_PARAMS = %i[guild_id channel_id webhook_id].freeze

      # @return [Symbol, String] HTTP verb to be used when accessing the API
      #   path.
      attr_reader :verb

      # @return [String] Unformatted API path, using Kernel.format
      #   syntax referencing keys in {params}.
      attr_reader :key

      # @return [String] String that defines an endpoint based on HTTP verb,
      #   API path, and major parameter if any.
      attr_reader :rl_key

      # @return [Hash] Parameters that are passed to be used when formatting
      #   the API path.
      attr_reader :params

      # Create a new route to be used with {Client#request}
      # @param verb [#to_sym] The HTTP verb to be used when accessing the API path.
      # @param key [String] The unformatted route using Kernel.format syntax to
      #   incorporate the data provided in `params`.
      # @param params [Hash<String, #to_s>] Parameters passed when formatting `key`.
      def initialize(verb, key, **params)
        @verb = verb.downcase.to_sym
        @key = key
        @params = params
        @rl_key = "#{@verb}:#{@key}:#{major_param}"
      end

      # Format the route with the given params
      # @return [String] Formatted API path.
      def format
        return @key if @params.empty?

        Kernel.format(@key, @params) if @params.any?
      end

      # @return [String, Integer, nil] The major param value of the route key if any
      def major_param
        params.slice(*MAJOR_PARAMS).values.first
      end

      # Compare a {Route} or {Route} like object (responds to `#verb`, `#key`, and `#params`).
      # @param other [Route]
      # @return [true, false]
      def ==(other)
        @verb == other.verb && @key == other.key && @params == other.params
      end
    end
  end
end
