# frozen_string_literal: true

require 'faraday'
require 'faraday/logging/formatter'

module Vox
  module HTTP
    # Collection of middleware used to process requests internally.
    module Middleware
      # @!visibility private
      class LogFormatter < Faraday::Logging::Formatter
        # Request processing
        def request(env)
          req_id = env.request.context[:trace]

          log_request_info(env, req_id)
          # Debug just logs the response with the response body
          log_request_debug(env, req_id) if env.request_headers['Content-Type'] == 'application/json'
          debug { "{#{req_id}} [OUT] #{env.request_headers}" }
        end

        # Info level logging for requests. Logs the HTTP verb, the url path, query string arguments, and
        # request body size.
        def log_request_info(env, req_id)
          query_string = "?#{env.url.query}" if env.url.query
          size = env.body.respond_to?(:size) ? env.body.size : env.request_headers['Content-Length']
          info { "{#{req_id}} [OUT] #{env.method} #{env.url.path}#{query_string} (#{size || 0})" }
        end

        # Debug level logging for requests. Displays the request body.
        def log_request_debug(env, req_id)
          debug { "{#{req_id}} [OUT] #{env.body}" }
        end

        # Response processing
        def response(env)
          resp = env.response
          req_id = env.request.context[:trace]

          log_response_error(env, resp, req_id) unless resp.success?
          log_response_info(env, resp, req_id)
          log_response_debug(env, resp, req_id) unless resp.body.empty?
        end

        # Error level logging for responses. Logs status code, url path, and response body.
        def log_response_error(env, resp, req_id)
          error { "{#{req_id}} [IN] #{resp.status} #{env.url.path} #{resp.body}" }
        end

        # Info level logging for responses. Logs status code, url path, and body size.
        def log_response_info(env, resp, req_id)
          info { "{#{req_id}} [IN] #{resp.status} #{env.url.path} (#{resp.body&.size || 0})" }
        end

        # Debug level logging for responses. Logs the response body.
        def log_response_debug(_env, resp, req_id)
          debug { "{#{req_id}} [IN] #{resp.body}" }
        end
      end
    end
  end
end
