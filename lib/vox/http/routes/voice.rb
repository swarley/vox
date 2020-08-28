# frozen_string_literal: true

require 'vox/http/route'
require 'vox/http/util'

module Vox
  module HTTP
    module Routes
      # Mixin for voice routes.
      module Voice
        # Lists voice regions that can be used when creating guilds.
        # @return [Array<Hash<Symbol, Object>>] An array of [voice region](https://discord.com/developers/docs/resources/voice#voice-region-object)
        #   objects.
        # @vox.api_docs https://discord.com/developers/docs/resources/voice#list-voice-regions
        def list_voice_regions
          route = Route.new(:GET, '/voice/regions')
          request(route)
        end
      end
    end
  end
end
