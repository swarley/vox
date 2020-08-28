# frozen_string_literal: true

require 'vex/http/route'
require 'vex/http/util'

module Vex
  module HTTP
    module Routes
      # Mixin for guild routes.
      module Guild
        include Util

        # @param name [String] The name of the guild.
        # @param region [String] A [voice region](https://discord.com/developers/docs/resources/voice#voice-region-object).
        # @param icon [UploadIO] TODO
        # @param verification_level [Integer] [Verification level](https://discord.com/developers/docs/resources/guild#guild-object-verification-level).
        # @param default_message_notifications [Integer] [Notification level](https://discord.com/developers/docs/resources/guild#guild-object-default-message-notification-level).
        # @param explicit_content_filter [Integer] [Content filter level](https://discord.com/developers/docs/resources/guild#guild-object-explicit-content-filter-level).
        # @param roles [Array<Hash<Symbol, Object>>] An array of [role](https://discord.com/developers/docs/topics/permissions#role-object)
        #   objects.
        # @param channels [Array<Hash<Symbol, Object>>] An array of partial [channel](https://discord.com/developers/docs/resources/channel#channel-object)
        #   objects.
        # @param afk_channel_id [String, Integer] The ID for the AFK channel.
        # @param afk_timeout [Integer] AFK timeout in seconds.
        # @param system_channel_id [String, Integer] The ID of the channel where guild notices such as welcome messages
        #   and boost events are posted
        # @vex.api_docs https://discord.com/developers/docs/resources/guild#create-guild
        def create_guild(name:, region: :undef, icon: :undef, verification_level: :undef,
                         default_message_notifications: :undef, explicit_content_filter: :undef,
                         roles: :undef, channels: :undef, afk_channel_id: :undef,
                         afk_timeout: :undef, system_channel_id: :undef)
          json = filter_undef(
            {
              name: name, region: region, icon: icon, verification_level: verification_level,
              default_message_notifications: default_message_notifications,
              explicit_content_filter: explicit_content_filter, roles: roles, channels: channels,
              afk_channel_id: afk_channel_id, afk_timeout: afk_timeout, system_channel_id: system_channel_id
            }
          )
          request(Route.new(:POST, '/guilds'), json: json)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#get-guild-preview
        def get_guild_preview(guild_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/preview', guild_id: guild_id))
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#modify-guild
        def modify_guild(guild_id, name: :undef, region: :undef, verification_level: :undef,
                         default_message_notifications: :undef, explicit_content_filter: :undef,
                         afk_channel_id: :undef, afk_timeout: :undef, icon: :undef, owner_id: :undef,
                         splash: :undef, banner: :undef, system_channel_id: :undef,
                         rules_channel_id: :undef, public_updates_channel_id: :undef,
                         preferred_locale: :undef, reason: nil)
          json = filter_undef(
            {
              name: name, region: region, verification_level: verification_level,
              default_message_notifications: default_message_notifications,
              explicit_content_filter: explicit_content_filter, afk_channel_id: afk_channel_id,
              afk_timeout: afk_timeout, icon: icon, owner_id: owner_id, splash: splash, banner: banner,
              system_channel_id: system_channel_id, rules_channel_id: rules_channel_id,
              public_updates_channel_id: public_updates_channel_id, preferred_locale: preferred_locale
            }
          )
          request(Route.new(:PATCH, '/guilds/%{guild_id}', guild_id: guild_id), json: json, reason: reason)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#delete-guild
        def delete_guild(guild_id)
          request(Route.new(:DELETE, '/guilds/%{guild_id}', guild_id: guild_id))
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#get-guild-channels
        def get_guild_channels(guild_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/channels', guild_id: guild_id))
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#create-guild-channel
        def create_guild_channel(guild_id, name: :undef, type: :undef, topic: :undef, bitrate: :undef,
                                 user_limit: :undef, rate_limit_per_user: :undef, position: :undef,
                                 permission_overwrites: :undef, parent_id: :undef, nsfw: :undef, reason: nil)
          json = filter_undef(
            {
              name: name, type: type, topic: topic, bitrate: bitrate, user_limit: user_limit,
              rate_limit_per_user: rate_limit_per_user, position: position,
              permission_overwrites: permission_overwrites, parent_id: parent_id, nsfw: nsfw
            }
          )
          request(Route.new(:POST, '/guilds/%{guild_id}/channels', guild_id: guild_id), json: json, reason: reason)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#modify-guild-channel-positions
        def modify_guild_channel_positions(guild_id, positions, reason: nil)
          route = Route.new(:PATCH, '/guilds/%{guild_id}/channels', guild_id: guild_id)
          request(route, json: positions, reason: reason)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#get-guild-member
        def get_guild_member(guild_id, user_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/members/%{user_id}', guild_id: guild_id, user_id: user_id))
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#list-guild-members
        def list_guild_members(guild_id, limit: :undef, after: :undef)
          params = filter_undef({ limit: limit, after: after })
          request(Route.new(:GET, '/guilds/%{guild_id}/members', guild_id: guild_id), query: params)
        end

        # @vex.oauth_scope guilds.join
        def add_guild_member(guild_id, user_id, access_token:, nick: :undef, roles: :undef, mute: :undef, deaf: :undef)
          json = filter_undef({ access_token: access_token, nick: nick, roles: roles, mute: mute, deaf: deaf })
          route = Route.new(:PUT, '/guilds/%{guild_id}/members/%{user_id}', guild_id: guild_id, user_id: user_id)
          request(route, json: json)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#modify-guild-member
        def modify_guild_member(guild_id, user_id, nick: :undef, roles: :undef, mute: :undef, deaf: :undef,
                                channel_id: :undef, reason: nil)
          json = filter_undef({ nick: nick, roles: roles, mute: mute, deaf: deaf, channel_id: channel_id })
          route = Route.new(:PATCH, '/guilds/%{guild_id}/members/%{user_id}', guild_id: guild_id, user_id: user_id)
          request(route, json: json, reason: reason)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#modify-current-user-nick
        def modify_current_user_nick(guild_id, nick: :undef, reason: nil)
          json = filter_undef({ nick: nick })
          route = Route.new(:PATCH, '/guilds/%{guild_id}/members/@me/nick', guild_id: guild_id)
          request(route, json: json, reason: reason)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#add-guild-member-role
        def add_guild_member_role(guild_id, user_id, role_id, reason: nil)
          route = Route.new(:PUT, '/guilds/%{guild_id}/members/%{user_id}/roles/%{role_id}',
                            guild_id: guild_id, user_id: user_id, role_id: role_id)
          request(route, reason: reason)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#remove-guild-member-role
        def remove_guild_member_role(guild_id, user_id, role_id, reason: nil)
          route = Route.new(:DELETE, '/guilds/%{guild_id}/members/%{user_id}/roles/%{role_id}',
                            guild_id: guild_id, user_id: user_id, role_id: role_id)
          request(route, reason: reason)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#remove-guild-member
        def remove_guild_member(guild_id, user_id, reason: nil)
          route = Route.new(:DELETE, '/guilds/%{guild_id}/members/%{user_id}', guild_id: guild_id, user_id: user_id)
          request(route, reason: reason)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#get-guild-bans
        def get_guild_bans(guild_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/bans', guild_id: guild_id))
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#get-guild-ban
        def get_guild_ban(guild_id, user_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/bans/%{user_id}', guild_id: guild_id, user_id: user_id))
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#create-guild-ban
        def create_guild_ban(guild_id, user_id, deleted_message_days: :undef, reason: :undef)
          json = filter_undef({ deleted_message_days: deleted_message_days, reason: reason })
          route = Route.new(:PUT, '/guilds/%{guild_id}/bans/%{user_id}', guild_id: guild_id, user_id: user_id)
          request(route, json: json)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#remove-guild-ban
        def remove_guild_ban(guild_id, user_id, reason: nil)
          route = Route.new(:DELETE, '/guilds/%{guild_id}/bans/%{user_id}', guild_id: guild_id, user_id: user_id)
          request(route, reason: reason)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#get-guild-roles
        def get_guild_roles(guild_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/roles', guild_id: guild_id))
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#create-guild-role
        def create_guild_role(guild_id, name: :undef, permissions: :undef, color: :undef, hoist: :undef,
                              mentionable: :undef, reason: nil)
          json = filter_undef({ name: name, permissions: permissions, color: color,
                                hoist: hoist, mentionable: mentionable })
          request(Route.new(:POST, '/guilds/%{guild_id}/roles', guild_id: guild_id), json: json, reason: reason)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#modify-guild-role-positions
        def modify_guild_role_positions(guild_id, positions, reason: nil)
          request(Route.new(:PATCH, '/guilds/%{guild_id}/roles', guild_id: guild_id), json: positions, reason: reason)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#modify-guild-role
        def modify_guild_role(guild_id, role_id, name: :undef, permissions: :undef, color: :undef, hoist: :undef,
                              mentionable: :undef, reason: nil)
          json = filter_undef({ name: name, permissions: permissions, color: color,
                                hoist: hoist, mentionable: mentionable })
          route = Route.new(:PATCH, '/guilds/%{guild_id}/roles/%{role_id}', guild_id: guild_id, role_id: role_id)
          request(route, json: json, reason: reason)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#delete-guild-role
        def delete_guild_role(guild_id, role_id, reason: nil)
          route = Route.new(:DELETE, '/guilds/%{guild_id}/roles/%{role_id}', guild_id: guild_id, role_id: role_id)
          request(route, reason: reason)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#get-guild-prune-count
        def get_guild_prune_count(guild_id, days: :undef, include_roles: :undef)
          params = filter_undef({ days: days, include_roles: include_roles })
          request(Route.new(:GET, '/guilds/%{guild_id}/prune', guild_id: guild_id), query: params)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#begin-guild-prune
        def begin_guild_prune(guild_id, days: :undef, compute_prune_count: :undef, include_roles: :undef, reason: nil)
          json = filter_undef({ days: days, compute_prune_count: compute_prune_count, include_roles: include_roles })
          route = Route.new(:POST, '/guilds/%{guild_id}/prune', guild_id: guild_id)
          request(route, json: json, reason: reason)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#get-guild-voice-regions
        def get_guild_voice_regions(guild_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/regions', guild_id: guild_id))
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#get-guild-invites
        def get_guild_invites(guild_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/invites', guild_id: guild_id))
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#get-guild-integrations
        def get_guild_integrations(guild_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/integrations', guild_id: guild_id))
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#create-guild-integration
        def create_guild_integration(guild_id, type:, id:)
          json = { type: type, id: id }
          request(Route.new(:POST, '/guilds/%{guild_id}/integrations', guild_id: guild_id), json: json)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#modify-guild-integration
        def modify_guild_integration(guild_id, integration_id, expire_behavior: :undef, expire_grace_period: :undef,
                                     enable_emoticons: :undef, reason: nil)
          json = filter_undef({ expire_behavior: expire_behavior, expire_grace_period: expire_grace_period,
                                enable_emoticons: enable_emoticons })
          route = Route.new(:PATCH, '/guilds/%{guild_id}/integrations/%{integration_id}',
                            guild_id: guild_id, integration_id: integration_id)
          request(route, json: json, reason: reason)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#delete-guild-integration
        def delete_guild_integration(guild_id, integration_id, reason: nil)
          route = Route.new(:DELETE, '/guilds/%{guild_id}/integrations/%{integration_id}',
                            guild_id: guild_id, integration_id: integration_id)
          request(route, reason: reason)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#sync-guild-integration
        def sync_guild_integration(guild_id, integration_id, reason: nil)
          route = Route.new(:POST, '/guilds/%{guild_id}/integrations/%{integration_id}/sync',
                            guild_id: guild_id, integration_id: integration_id)
          request(route, reason: reason)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#get-guild-widget
        def get_guild_widget(guild_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/widget', guild_id: guild_id))
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#modify-guild-widget
        def modify_guild_widget(guild_id, enabled: :undef, channel_id: :undef, reason: nil)
          json = filter_undef({ enabled: enabled, channel_id: channel_id })
          route = Route.new(:PATCH, '/guilds/%{guild_id}/widget', guild_id: guild_id)
          request(route, json: json, reason: reason)
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#get-guild-vanity-url
        def get_guild_vanity_url(guild_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/vanity-url', guild_id: guild_id))
        end

        # @vex.api_docs https://discord.com/developers/docs/resources/guild#get-guild-widget-image
        def get_guild_widget_image(guild_id, style: :undef)
          params = filter_undef({ style: style })
          route = Route.new(:GET, '/guilds/%{guild_id}/widget.png', guild_id: guild_id)
          request(route, query: params, raw: true)
        end
      end
    end
  end
end
