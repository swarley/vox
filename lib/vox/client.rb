# frozen_string_literal: true

require 'vox/http/client'
require 'vox/gateway/client'
require 'vox/cache/manager'
require 'vox/objects/user'

module Vox



  class Client
    include EventEmitter

    attr_reader :http
    attr_reader :gateway

    def initialize(token:, cache_manager: Cache::Manager.new, gateway_options: {}, http_options: {}, gateway: nil, http: nil)
      @cache_manager = cache_manager
      @http = http || HTTP::Client.new(**{ token: token }.merge(http_options))
      @gateway = gateway || create_gateway(token: token, options: gateway_options)
    end

    def cache(cache_key, key, cached = true, &block)
      puts "caching #{cache_key} #{key}"
      if cached
        @cache_manager.get(cache_key, key) || @cache_manager.set(cache_key, key, block.call)
      else
        @cache_manager.set(cache_key, key, block.call)
      end
    end

    def user(id, cached: true)
      cache(:user, id, cached) { User.new(self, @http.get_user(id)) }
    end

    def current_user(cached: true)
      data = cache(:user, :@me, cached) { Profile.new(self, @http.get_current_user) }
      @cache_manager.set(:user, data.id, data)
    end

    private

    def create_gateway(token:, options: {})
      options[:url] ||= @http.get_gateway_bot[:url]
      Vox::Gateway::Client.new(**{ token: token }.merge(**options))
    end
  end
end