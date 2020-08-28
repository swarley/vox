# frozen_string_literal: true

require 'vox/http/route'
require 'vox/http/util'

module Vox
  module HTTP
    module Routes
      # Mixin for invite routes.
      module Invite
        include Util

        # Get an invite by its code.
        # @param invite_code [String]
        # @param with_counts [true, false] Whether the invite object should contain approximate member counts.
        # @return [Hash<Symbol, Object>] The [invite](https://discord.com/developers/docs/resources/invite#invite-object)
        #   object.
        # @vox.api_docs https://discord.com/developers/docs/resources/invite#get-invite
        def get_invite(invite_code, with_counts: :undef)
          route = Route.new(:GET, '/invites/%{invite_code}', invite_code: invite_code)
          request(route, query: filter_undef({ with_counts: with_counts }))
        end

        # Delete an invite by its code.
        # @param invite_code [String]
        # @return [Hash<Symbol, Object>] The deleted [invite](https://discord.com/developers/docs/resources/invite#invite-object)
        #   object.
        # @vox.permissions MANAGE_CHANNELS or MANAGE_GUILD
        # @vox.api_docs https://discord.com/developers/docs/resources/invite#delete-invite
        def delete_invite(invite_code, reason: nil)
          route = Route.new(:DELETE, '/invites/%{invite_code}', invite_code: invite_code)
          request(route, reason: reason)
        end
      end
    end
  end
end
