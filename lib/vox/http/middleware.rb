# frozen_string_literal: true

require 'faraday'
require 'logging'

require 'vox/http/middleware/rate_limiter'
require 'vox/http/middleware/log_formatter'

log = Logging.logger['Vox::HTTP']

log.debug { 'Registering rate_limiter middleware' }
Faraday::Middleware.register_middleware(
  vox_ratelimiter: Vox::HTTP::Middleware::RateLimiter
)
