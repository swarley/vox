# frozen_string_literal: true

require 'vex/http/route'
require 'vex/http/util'

module Vex
  module HTTP
    module Routes
      # Mixin for user routes.
      module User
        include Util

        # rubocop:disable Naming/AccessorMethodName

        # Get information about the current user.
        # @return [Hash<Symbol, Object>] The [user](https://discord.com/developers/docs/resources/user#user-object)
        #   object for the current user.
        # @vex.oauth_scope identify
        # @vex.api_docs https://discord.com/developers/docs/resources/user#get-current-user
        def get_current_user
          request(Route.new(:GET, '/users/@me'))
        end

        # Get information about a user by ID.
        # @return [Hash<Symbol, Object] The [user](https://discord.com/developers/docs/resources/user#user-object)
        #   object for the target user.
        # @vex.api_docs https://discord.com/developers/docs/resources/user#get-user
        def get_user(user_id)
          request(Route.new(:GET, '/users/%{user_id}', user_id: user_id))
        end

        # Modify the current user.
        # @param username [String]
        # @param avatar [UploadIO]
        # @return [Hash<Symbol, Object>] The updated [user](https://discord.com/developers/docs/resources/user#user-object)
        #   object.
        # @vex.api_docs https://discord.com/developers/docs/resources/user#modify-current-user
        def modify_current_user(username: :undef, avatar: :undef)
          avatar = if avatar != :undef && !avatar.nil?
                     image_data = avatar.io.read
                     "data:#{avatar.content_type};base64,#{Base64.encode64(image_data)}"
                   else
                     :undef
                   end
          json = filter_undef({ username: username, avatar: avatar })
          request(Route.new(:PATCH, '/users/@me'), json: json)
        end

        # List the guilds that the current user is in.
        # @param before [String, Integer] Get guilds before this ID.
        # @param after [String, Integer] Get guilds after this ID.
        # @param limit [String, Integer] Maximum number of guilds to return.
        # @return [Array<Hash<Symbol, Object>>] An array of [guild](https://discord.com/developers/docs/resources/guild#guild-object)
        #   objects.
        # @vex.oauth_scope guilds
        # @vex.api_docs https://discord.com/developers/docs/resources/user#get-current-user-guilds
        def get_current_user_guilds(before: :undef, after: :undef, limit: :undef)
          params = filter_undef({ before: before, after: after, limit: limit })
          request(Route.new(:GET, '/users/@me/guilds'), query: params)
        end

        # Leave a guild.
        # @param guild_id [String, Integer] The ID of the guild to leave.
        # @return [nil] Returns nil on success.
        # @vex.api_docs https://discord.com/developers/docs/resources/user#get-current-user-guilds
        def leave_guild(guild_id)
          request(Route.new(:DELETE, '/users/@me/guilds/%{guild_id}', guild_id: guild_id))
        end

        # Get a list of the current user's DM channels.
        # @return [Array<Hash<Symbol, Object>>] An array of [DM channel](https://discord.com/developers/docs/resources/channel#channel-object)
        #   objects.
        # @vex.api_docs https://discord.com/developers/docs/resources/user#get-user-dms
        def get_user_dms
          request(Route.new(:GET, '/users/@me/channels'))
        end

        # Create a new DM channel with a user.
        # @param recipient_id [String, Integer] The ID of the recipient to open a DM with.
        # @return [Hash<Symbol, Object>] The [DM channel](https://discord.com/developers/docs/resources/channel#channel-object)
        #   object.
        # @vex.api_docs https://discord.com/developers/docs/resources/user#create-dm
        def create_dm(recipient_id)
          request(Route.new(:POST, '/users/@me/channels'), json: { recipient_id: recipient_id })
        end

        # Create a new DM with multiple users.
        # @param access_tokens [Array<String, Integer>] Access tokens of users that have granted your app the `gdm.join`
        #   scope.
        # @param nicks [Hash<(String, Integer), String>] A hash mapping user IDs to their nicknames.
        # @note This endpoint was intended for a now deprecated SDK. DMs created with this endpoint are not
        #   visible in the Discord client.
        # @note This endpoint is limited to 10 active group DMs.
        # @vex.oauth_scope gdm.join
        # @vex.api_docs https://discord.com/developers/docs/resources/user#create-group-dm
        def create_group_dm(access_tokens, nicks: :undef)
          json = filter_undef({ access_tokens: access_tokens, nicks: nicks })
          request(Route.new(:POST, '/users/@me/channels'), json: json)
        end

        # Get a list of connection objects for the current user.
        # @return [Array<Hash<Symbol, Object>>] An array of [connection](https://discord.com/developers/docs/resources/user#connection-object)
        #   objects.
        # @vex.oauth_scope connections
        # @vex.api_docs https://discord.com/developers/docs/resources/user#get-user-connections
        def get_user_connections
          request(Route.new(:GET, '/users/@me/connections'))
        end

        # rubocop:enable Naming/AccessorMethodName
      end
    end
  end
end
