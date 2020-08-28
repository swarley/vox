# frozen_string_literal: true

require 'faraday'
require 'logging'

require 'vex/http/middleware/rate_limiter'
require 'vex/http/middleware/log_formatter'

log = Logging.logger['Vex::HTTP']

log.debug { 'Registering rate_limiter middleware' }
Faraday::Middleware.register_middleware(
  vex_ratelimiter: Vex::HTTP::Middleware::RateLimiter
)
