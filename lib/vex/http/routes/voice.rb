# frozen_string_literal: true

require 'vex/http/route'
require 'vex/http/util'

module Vex
  module HTTP
    module Routes
      # Mixin for voice routes.
      module Voice
        # Lists voice regions that can be used when creating guilds.
        # @return [Array<Hash<Symbol, Object>>] An array of [voice region](https://discord.com/developers/docs/resources/voice#voice-region-object)
        #   objects.
        # @vex.api_docs https://discord.com/developers/docs/resources/voice#list-voice-regions
        def list_voice_regions
          route = Route.new(:GET, '/voice/regions')
          request(route)
        end
      end
    end
  end
end
