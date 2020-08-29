# frozen_string_literal: true

require 'vox/http/route'
require 'vox/http/util'

module Vox
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
        # @return [Hash<Symbol, Object>] The created [guild](https://discord.com/developers/docs/resources/guild#guild-object)
        #   object.
        # @note This endpoint can only be used by bots in less than 10 guilds.
        # @note When using the `roles` parameter, the first member of the array is used to modify the `@everyone` role.
        # @note When using the `role` parameter, the `id` field in each object is an integer placeholder that will be
        #   replaced by the api. The integer placeholder you use is for reference in channel permission overwrites.
        # @note When using the `channels` parameter, the `position` field is ignored.
        # @note When using the `channels` parameter, the `id` field is an integer placeholder that will be replaced by
        #   the api. This is used for `GUILD_CATEGORY` channel types to allow you to reference a `parent_id` in other
        #   channels.
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#create-guild
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

        # Get the guild object for the given ID.
        # @param guild_id [String, Integer] The ID of the target guild.
        # @param with_counts [true, false] Whether the response should include `approximate_member_count`
        #   and `approximate_presence_count` fields.
        # @return [Hash<Symbol, Object>] The target [guild](https://discord.com/developers/docs/resources/guild#guild-object)
        #   object.
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#get-guild
        def get_guild(guild_id, with_counts: :undef)
          params = filter_undef({ with_counts: with_counts })
          request(Route.new(:GET, '/guilds/%{guild_id}', guild_id: guild_id), query: params)
        end

        # Get a guild preview for a public guild, even if the user is not in the guild.
        # @param guild_id [String, Integer] The ID of the target guild.
        # @return [Hash<Symbol, Object>] The target [guild](https://discord.com/developers/docs/resources/guild#guild-object)
        #   object.
        # @note This endpoint is only for public guilds.
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#get-guild-preview
        def get_guild_preview(guild_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/preview', guild_id: guild_id))
        end

        # @param guild_id [String, Integer]
        # @param name [String]
        # @param region [String]
        # @param verification_level [Integer]
        # @param default_message_notifications [Integer]
        # @param explicit_content_filter [Integer]
        # @param splash [String]
        # @param banner [String]
        # @param system_channel_id [String, Integer]
        # @param rules_channel_id [String, Integer]
        # @param public_updates_channel_id [String, Integer]
        # @param preferred_locale [String]
        # @param reason [String]
        # @return [Hash<Symbol, Object>] The modified [guild](https://discord.com/developers/docs/resources/guild#guild-object)
        #   object.
        # @vox.permissions MANAGE_GUILD
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#modify-guild
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

        # Delete a guild by ID.
        # @param guild_id [String, Integer]  The ID of the guild to be deleted.
        # @return [nil] Returns `nil` on success.
        # @note The user must be the server owner.
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#delete-guild
        def delete_guild(guild_id)
          request(Route.new(:DELETE, '/guilds/%{guild_id}', guild_id: guild_id))
        end

        # Get a list of channels for a guild.
        # @param guild_id [String, Integer] The ID of the guild to fetch the channels of.
        # @return [Array<Hash<Symbol, Object>>] A list of [channel](https://discord.com/developers/docs/resources/channel#channel-object)
        #   objects.
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#get-guild-channels
        def get_guild_channels(guild_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/channels', guild_id: guild_id))
        end

        # Create a new channel in a guild.
        # @param guild_id [String, Integer] The ID of the channel to create a channel in.
        # @param name [String] The name of the channel.
        # @param type [Integer] The [type](https://discord.com/developers/docs/resources/channel#channel-object-channel-types)
        #   of channel to create.
        # @param topic [String] The channel topic, between 0-1024 characters.
        # @param bitrate [Integer] The bitrate for the voice channel (voice only).
        # @param user_limit [Integer] The user limit of the voice channel (voice only).
        # @param rate_limit_per_user [Integer] The amount of seconds a user has to wait before sending another message,
        #   between 0-21600. Bots and users with `MANAGE_MESSAGES` or `MANAGE_CHANNELS` are unaffected.
        # @param position [Integer] The sorting position of this channel.
        # @param permission_overwrites [Array<Hash<Symbol, Integer>>] An array of [permission overwrite](https://discord.com/developers/docs/resources/channel#overwrite-object)
        #   objects.
        # @param parent_id [String, Integer] The ID of the parent category for a channel.
        # @param nsfw [true, false] Whether the channel is NSFW.
        # @param reason [String] The reason this channel is being created.
        # @return [Hash<Symbol, Object>] The created [channel](https://discord.com/developers/docs/resources/channel#channel-object)
        #   object.
        # @vox.permissions MANAGE_CHANNELS
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#create-guild-channel
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

        # Modify the positions of a set of channels.
        # @param guild_id [String, Integer] The ID of the target guild.
        # @param positions
        # @param reason [String]
        # @return [nil] Returns `nil` on success.
        # @note Only channels to be modified are required, with the minimum count being two channels.
        # @vox.permissions MANAGE_CHANNELS
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#modify-guild-channel-positions
        def modify_guild_channel_positions(guild_id, positions, reason: nil)
          route = Route.new(:PATCH, '/guilds/%{guild_id}/channels', guild_id: guild_id)
          request(route, json: positions, reason: reason)
        end

        # Fetch information about a guild member.
        # @param guild_id [String, Integer] The ID of the target guild.
        # @param user_id [String, Integer] The ID of the target user.
        # @return [Hash<Symbol, Object>] The target [guild member](https://discord.com/developers/docs/resources/guild#guild-member-object)
        #   object.
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#get-guild-member
        def get_guild_member(guild_id, user_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/members/%{user_id}', guild_id: guild_id, user_id: user_id))
        end

        # Fetch a list of guild members.
        # @param guild_id [String, Integer] The ID of the target guild.
        # @param limit [Integer] The maximum amount of guild members to return.
        # @param after [String, Integer] Fetch users after this ID.
        # @return [Array<Hash<Symbol, Object>>] A list of [guild member](https://discord.com/developers/docs/resources/guild#guild-member-object)
        #   objects.
        # @note In the future this will require [priviledged intents](https://discord.com/developers/docs/topics/gateway#privileged-intents).
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#list-guild-members
        def list_guild_members(guild_id, limit: :undef, after: :undef)
          params = filter_undef({ limit: limit, after: after })
          request(Route.new(:GET, '/guilds/%{guild_id}/members', guild_id: guild_id), query: params)
        end

        # Add a member using an `access_token`.
        # @param guild_id [String, Integer] The ID of the guild to join the user to.
        # @return [Hash<Symbol, Object>] The created [guild member](https://discord.com/developers/docs/resources/guild#guild-member-object)
        #   object.
        # @vox.oauth_scope guilds.join
        # @vox.permissions CREATE_INSTANT_INVITE
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#add-guild-member
        def add_guild_member(guild_id, user_id, access_token:, nick: :undef, roles: :undef, mute: :undef, deaf: :undef)
          json = filter_undef({ access_token: access_token, nick: nick, roles: roles, mute: mute, deaf: deaf })
          route = Route.new(:PUT, '/guilds/%{guild_id}/members/%{user_id}', guild_id: guild_id, user_id: user_id)
          request(route, json: json)
        end

        # Modify attributes of a guild member.
        # @param guild_id [String, Integer] The ID of the target guild.
        # @param user_id [String, Integer] The ID of the target user.
        # @param nick [String] The user's nickname.
        # @param roles [Array<String, Integer>] An array of IDs for roles the member is assigned.
        # @param mute [true, false] Whether the member is muted in voice channels.
        # @param deaf [true, false] Whether the member is deafened in voice channels.
        # @param channel_id [String, Integer] The ID of a channel to move a user to, if they are connected
        #   to voice.
        # @param reason [String]
        # @return [Hash<Symbol, Object>] The modified [guild member](https://discord.com/developers/docs/resources/guild#guild-member-object)
        #   object.
        # @note `mute` and `deaf` parameters will result in a {Error::BadRequest} if the target user is not
        #   in a voice channel.
        # @vox.permissions MANAGE_NICKNAMES (nick), MANAGE_ROLES (roles), MUTE_MEMBERS (mute),
        #   DEAFEN_MEMBERS (deafen), MOVE_MEMBERS (channel_id)
        # @note When moving members to channels, the API user must have permissions to connect to both channels as well
        #   as MOVE_MEMBERS
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#modify-guild-member
        def modify_guild_member(guild_id, user_id, nick: :undef, roles: :undef, mute: :undef, deaf: :undef,
                                channel_id: :undef, reason: nil)
          json = filter_undef({ nick: nick, roles: roles, mute: mute, deaf: deaf, channel_id: channel_id })
          route = Route.new(:PATCH, '/guilds/%{guild_id}/members/%{user_id}', guild_id: guild_id, user_id: user_id)
          request(route, json: json, reason: reason)
        end

        # Update the nickname of the current user on a given guild.
        # @param guild_id [String, Integer] The ID of the target guild.
        # @param nick [String] The nickname to assign to the current user.
        # @param reason [String] The reason the user's nickname is being changed.
        # @return [Hash<:name, String>] The updated nickname.
        # @vox.permissions CHANGE_NICKNAME
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#modify-current-user-nick
        def modify_current_user_nick(guild_id, nick: :undef, reason: nil)
          json = filter_undef({ nick: nick })
          route = Route.new(:PATCH, '/guilds/%{guild_id}/members/@me/nick', guild_id: guild_id)
          request(route, json: json, reason: reason)
        end

        # Add a role to a guild member.
        # @param guild_id [String, Integer] The ID of the target guild.
        # @param user_id [String, Integer] The ID of the user to assign role to.
        # @param role_id [String, Integer] The ID of the role to assign to a user.
        # @param reason [String] The reason a role is being added to a user.
        # @return [nil] Returns `nil` on success.
        # @vox.permissions MANAGE_ROLES
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#add-guild-member-role
        def add_guild_member_role(guild_id, user_id, role_id, reason: nil)
          route = Route.new(:PUT, '/guilds/%{guild_id}/members/%{user_id}/roles/%{role_id}',
                            guild_id: guild_id, user_id: user_id, role_id: role_id)
          request(route, reason: reason)
        end

        # Remove a role from a guild member.
        # @param guild_id [String, Integer] The ID of the target guild.
        # @param user_id [String, Integer] The ID of the target user to remove a role from.
        # @param role_id [String, Integer] The ID of the role to remove from a target user.
        # @param reason [String] The reason a role is being removed from a user.
        # @return [nil] Returns `nil` on success.
        # @vox.permissions MANAGE_ROLES
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#remove-guild-member-role
        def remove_guild_member_role(guild_id, user_id, role_id, reason: nil)
          route = Route.new(:DELETE, '/guilds/%{guild_id}/members/%{user_id}/roles/%{role_id}',
                            guild_id: guild_id, user_id: user_id, role_id: role_id)
          request(route, reason: reason)
        end

        # Kick a member from a guild.
        # @param guild_id [String, Integer] The ID of the guild to kick the user from.
        # @param user_id [String, Integer] The ID of the user being kicked.
        # @param reason [String] The reason a user is being kicked.
        # @return [nil] Returns `nil` on success.
        # @vox.permissions KICK_MEMBERS
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#remove-guild-member
        def remove_guild_member(guild_id, user_id, reason: nil)
          route = Route.new(:DELETE, '/guilds/%{guild_id}/members/%{user_id}', guild_id: guild_id, user_id: user_id)
          request(route, reason: reason)
        end

        # Fetch a list of bans for a guild.
        # @param guild_id [String, Integer] The ID of a guild to fetch bans for.
        # @return [Array<Hash<Symbol, Object>>] A list of [ban](https://discord.com/developers/docs/resources/guild#ban-object)
        #   objects for the guild.
        # @vox.permissions BAN_MEMBERS
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#get-guild-bans
        def get_guild_bans(guild_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/bans', guild_id: guild_id))
        end

        # Get a ban object for a given user.
        # @param guild_id [String, Integer] The ID of the target guild to retrieve a ban from.
        # @param user_id [String, Integer] The ID of a user to retrieve a ban for.
        # @return [Hash<Symbol, Object>] The target [ban](https://discord.com/developers/docs/resources/guild#ban-object)
        #   object.
        # @vox.permissions BAN_MEMBERS
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#get-guild-ban
        def get_guild_ban(guild_id, user_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/bans/%{user_id}', guild_id: guild_id, user_id: user_id))
        end

        # Ban a user from a guild.
        # @param guild_id [String, Integer] The ID of a guild to ban a user from.
        # @param user_id [String, Integer] The ID of a user to ban.
        # @param deleted_message_days [Integer] The number of days to delete messages for, between 0-7.
        # @param reason [String] The reason a user is being banned.
        # @return [nil] Returns `nil` on success.
        # @vox.permissions BAN_MEMBERS
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#create-guild-ban
        def create_guild_ban(guild_id, user_id, deleted_message_days: :undef, reason: :undef)
          json = filter_undef({ deleted_message_days: deleted_message_days, reason: reason })
          route = Route.new(:PUT, '/guilds/%{guild_id}/bans/%{user_id}', guild_id: guild_id, user_id: user_id)
          request(route, json: json)
        end

        # Unban a user from a guild.
        # @param guild_id [String, Integer] The ID of a guild to remove a ban from.
        # @param user_id [String, Integer] The ID of a user to unban.
        # @param reason [String] The reason a user is being unbanned.
        # @return [nil] Returns `nil` on success.
        # @vox.permissions BAN_MEMBERS
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#remove-guild-ban
        def remove_guild_ban(guild_id, user_id, reason: nil)
          route = Route.new(:DELETE, '/guilds/%{guild_id}/bans/%{user_id}', guild_id: guild_id, user_id: user_id)
          request(route, reason: reason)
        end

        # Fetch a list of roles for a guild.
        # @param guild_id [String, Integer] The ID of a guild to retrieve roles for.
        # @return [Array<Hash<Symbol, Object>>] A list of [role](https://discord.com/developers/docs/topics/permissions#role-object)
        #   objects for the guild.
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#get-guild-roles
        def get_guild_roles(guild_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/roles', guild_id: guild_id))
        end

        # Create a role in a guild.
        # @param guild_id [String, Integer] The ID of a guild to create a role in.
        # @param name [String] The name for the role.
        # @param permissions [String, Integer] The bitwise value of the enabled/disabled permissions.
        # @param color [Integer] The RGB color value of the role.
        # @param hoist [true, false] Whether the role should be displayed separately in the sidebar.
        # @param mentionable [true, false] Whether the role should be mentionable.
        # @param reason [String] The reason a role is being created.
        # @return [Hash<Symbol, Object>] The created [role](https://discord.com/developers/docs/topics/permissions#role-object)
        #   object.
        # @vox.permissions MANAGE_ROLES
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#create-guild-role
        def create_guild_role(guild_id, name: :undef, permissions: :undef, color: :undef, hoist: :undef,
                              mentionable: :undef, reason: nil)
          json = filter_undef({ name: name, permissions: permissions, color: color,
                                hoist: hoist, mentionable: mentionable })
          request(Route.new(:POST, '/guilds/%{guild_id}/roles', guild_id: guild_id), json: json, reason: reason)
        end

        # Modify the positions of a set of role objects.
        # @param guild_id [String, Integer] The ID of the target guild.
        # @param positions [Array<Hash<:id, Integer>>] An array of objects mapping channel ID to position.
        # @param reason [String] The reason channel positions are being modified.
        # @return [Array<Hash<Symbol, Object>>] A list of the guild's [role](https://discord.com/developers/docs/topics/permissions#role-object)
        #   objects.
        # @vox.permissions MANAGE_ROLES
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#modify-guild-role-positions
        def modify_guild_role_positions(guild_id, positions, reason: nil)
          request(Route.new(:PATCH, '/guilds/%{guild_id}/roles', guild_id: guild_id), json: positions, reason: reason)
        end

        # Modify a guild role.
        # @param guild_id [String, Integer] The ID of the target guild.
        # @param role_id [String, Integer] The ID of a role to be modified.
        # @param name [String] The name of the role.
        # @param permissions [String, Integer] A bitwise value of the enabled/disabled permissions.
        # @param color [Integer] An RGB color value.
        # @param hoist [true, false] Whether the role should be displayed separately in the
        #   sidebar.
        # @param mentionable [true, false] Whether the role should be mentionable.
        # @param reason [String]
        # @return [Hash<Symbol, Object>] The modified [role](https://discord.com/developers/docs/topics/permissions#role-object)
        #   object.
        # @vox.permissions MANAGE_ROLES
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#modify-guild-role
        def modify_guild_role(guild_id, role_id, name: :undef, permissions: :undef, color: :undef, hoist: :undef,
                              mentionable: :undef, reason: nil)
          json = filter_undef({ name: name, permissions: permissions, color: color,
                                hoist: hoist, mentionable: mentionable })
          route = Route.new(:PATCH, '/guilds/%{guild_id}/roles/%{role_id}', guild_id: guild_id, role_id: role_id)
          request(route, json: json, reason: reason)
        end

        # Delete a guild role.
        # @param guild_id [String, Integer] The ID of the target guild.
        # @param role_id [String, Integer] The ID of the role to be deleted.
        # @param reason [String] The reason a role is being deleted.
        # @return [nil] Returns `nil` on success.
        # @vox.permissions MANAGE_ROLES
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#delete-guild-role
        def delete_guild_role(guild_id, role_id, reason: nil)
          route = Route.new(:DELETE, '/guilds/%{guild_id}/roles/%{role_id}', guild_id: guild_id, role_id: role_id)
          request(route, reason: reason)
        end

        # Get the result of a potential guild prune.
        # @param guild_id [String, Integer] The ID of the target guild.
        # @param days [Integer] The number of days to count prune for, 1 or more.
        # @param include_roles [Array<String, Integer>] Roles to include when calculating prune count.
        # @return [Hash<:pruned, Integer>] An object with a `pruned` key indicating how many members
        #   would be removed in a prune operation.
        # @vox.permissions KICK_MEMBERS
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#get-guild-prune-count
        def get_guild_prune_count(guild_id, days: :undef, include_roles: :undef)
          include_roles = include_roles.is_a?(Array) ? include_roles.join(',') : include_roles
          params = filter_undef({ days: days, include_roles: include_roles })
          request(Route.new(:GET, '/guilds/%{guild_id}/prune', guild_id: guild_id), query: params)
        end

        # Kick members that have been inactive for a provided duration.
        # @param guild_id [String, Integer] The ID of the guild to prune.
        # @param days [Integer] The number of days to prune, 1 or more.
        # @param compute_prune_count [true, false] Whether the `pruned` key is returned. Discouraged for
        #   large guilds.
        # @param include_roles [Array<String, Integer>] Roles to include in the prune.
        # @param reason [String] The reason a prune is being initiated.
        # @return [Hash<:pruned, (Integer, nil)>] An object with a `pruned` key indicating how many members
        #   were removed. Will be `nil` if `compute_prune_count` is set to false.
        # @vox.permissions KICK_MEMBERS
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#begin-guild-prune
        def begin_guild_prune(guild_id, days: :undef, compute_prune_count: :undef, include_roles: :undef, reason: nil)
          include_roles = include_roles.is_a?(Array) ? include_roles.join(',') : include_roles
          json = filter_undef({ days: days, compute_prune_count: compute_prune_count, include_roles: include_roles })
          route = Route.new(:POST, '/guilds/%{guild_id}/prune', guild_id: guild_id)
          request(route, json: json, reason: reason)
        end

        # Fetch a list of voice regions for a guild.
        # @param guild_id [String, Integer] The ID of the target guild.
        # @return [Array<Hash<Symbol, Object>>] A list of [voice region](https://discord.com/developers/docs/resources/voice#voice-region-object)
        #   objects for the guild.
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#get-guild-voice-regions
        def get_guild_voice_regions(guild_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/regions', guild_id: guild_id))
        end

        # Fetch a list of invites for a guild.
        # @param guild_id [String, Integer] The ID of the guild to fetch invites from.
        # @return [Array<Hash<Symbol, Object>>] A list of [invite](https://discord.com/developers/docs/resources/invite#invite-object)
        #   objects with additional [invite metadata](https://discord.com/developers/docs/resources/invite#invite-metadata-object)
        #   fields.
        # @vox.permissions MANAGE_GUILD
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#get-guild-invites
        def get_guild_invites(guild_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/invites', guild_id: guild_id))
        end

        # Fetch a list of integrations for a guild.
        # @param guild_id [String, Integer] The ID of the guild to fetch integrations for.
        # @return [Array<Hash<Symbol, Object>>] A list of [integration](https://discord.com/developers/docs/resources/guild#integration-object)
        #   objects for the guild.
        # @vox.permissions MANAGE_GUILD
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#get-guild-integrations
        def get_guild_integrations(guild_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/integrations', guild_id: guild_id))
        end

        # Create an integration for a guild.
        # @param guild_id [String, Integer] The ID of the guild to create an integration for.
        # @param type [Integer] The integration type.
        # @param id [String, Integer] The ID of the integration to add.
        # @return [nil] Returns `nil` on success.
        # @vox.permissions MANAGE_GUILD
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#create-guild-integration
        def create_guild_integration(guild_id, type:, id:)
          json = { type: type, id: id }
          request(Route.new(:POST, '/guilds/%{guild_id}/integrations', guild_id: guild_id), json: json)
        end

        # Modify a guild integration.
        # @param guild_id [String, Integer] The ID of a guild to modify an integration for.
        # @param integration_id [String, Integer] The ID of the integration to modify.
        # @param expire_behavior [Integer] The [expire behavior](https://discord.com/developers/docs/resources/guild#integration-object-integration-expire-behaviors)
        #   for this integration.
        # @param expire_grace_period The grace period in days before expiring subscribers.
        # @param enable_emoticons [true, false] Whether emoticons hsould be synced for this integration.
        #   Currently, twitch only.
        # @param reason [String] The reason an integration is being modified.
        # @return [nil] Returns `nil` on success.
        # @vox.permissions MANAGE_GUILD
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#modify-guild-integration
        def modify_guild_integration(guild_id, integration_id, expire_behavior: :undef, expire_grace_period: :undef,
                                     enable_emoticons: :undef, reason: nil)
          json = filter_undef({ expire_behavior: expire_behavior, expire_grace_period: expire_grace_period,
                                enable_emoticons: enable_emoticons })
          route = Route.new(:PATCH, '/guilds/%{guild_id}/integrations/%{integration_id}',
                            guild_id: guild_id, integration_id: integration_id)
          request(route, json: json, reason: reason)
        end

        # Delete a guild integration.
        # @param guild_id [String, Integer] The ID of a guild to delete an integration for.
        # @param integration_id [String, Integer] The ID of an integration to delete.
        # @param reason [String] The reason an integration is being deleted.
        # @return [nil] Returns `nil` on success.
        # @vox.permissions MANAGE_GUILD
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#delete-guild-integration
        def delete_guild_integration(guild_id, integration_id, reason: nil)
          route = Route.new(:DELETE, '/guilds/%{guild_id}/integrations/%{integration_id}',
                            guild_id: guild_id, integration_id: integration_id)
          request(route, reason: reason)
        end

        # Sync a guild integration.
        # @param guild_id [String, Integer] The ID of the target guild.
        # @param integration_id [String, Integer] The ID of the integration to sync.
        # @param reason [String] The reason an integration is being synced.
        # @return [nil] Returns `nil` on success.
        # @vox.permissions MANAGE_GUILD
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#sync-guild-integration
        def sync_guild_integration(guild_id, integration_id, reason: nil)
          route = Route.new(:POST, '/guilds/%{guild_id}/integrations/%{integration_id}/sync',
                            guild_id: guild_id, integration_id: integration_id)
          request(route, reason: reason)
        end

        # Fetch the guild widget object for a guild.
        # @param guild_id [String, Integer] The ID of a target guild.
        # @return [Hash<Symbol, Object>] The target [guild widget](https://discord.com/developers/docs/resources/guild#guild-widget-object)
        #   object.
        # @vox.permissions MANAGE_GUILD
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#get-guild-widget
        def get_guild_widget(guild_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/widget', guild_id: guild_id))
        end

        # Modify a guild widget object.
        # @param guild_id [String, Integer] The ID of the target guild.
        # @param enabled [true, false] Whether or not to enable the widget.
        # @param channel_id [String, Integer] The ID of the target channel.
        # @param reason [String] The reason this widget is being modified.
        # @return [Hash<Symbol, Object>] The modified [guild widget](https://discord.com/developers/docs/resources/guild#guild-widget-object)
        #   object.
        # @vox.permissions MANAGE_GUILD
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#modify-guild-widget
        def modify_guild_widget(guild_id, enabled: :undef, channel_id: :undef, reason: nil)
          json = filter_undef({ enabled: enabled, channel_id: channel_id })
          route = Route.new(:PATCH, '/guilds/%{guild_id}/widget', guild_id: guild_id)
          request(route, json: json, reason: reason)
        end

        # Get the vanity url for a guild.
        # @param guild_id [String, Integer] The ID of the target guild.
        # @return [Hash<(:code, :uses), Object>] A partial [invite](https://discord.com/developers/docs/resources/invite#invite-object)
        #   object with `code`, and `uses` keys. `code` will be `nil` if a vanity url is not set
        #   for the guild.
        # @vox.permissions MANAGE_GUILD
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#get-guild-vanity-url
        def get_guild_vanity_url(guild_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/vanity-url', guild_id: guild_id))
        end

        # Get the widget image of guild.
        # @param guild_id [String, Integer] The ID of a target guild.
        # @param style [String] The [widget style](https://discord.com/developers/docs/resources/guild#get-guild-widget-image-widget-style-options)
        #   to fetch.
        # @return [String] The PNG image data for the guild widget image.
        # @vox.api_docs https://discord.com/developers/docs/resources/guild#get-guild-widget-image
        def get_guild_widget_image(guild_id, style: :undef)
          params = filter_undef({ style: style })
          route = Route.new(:GET, '/guilds/%{guild_id}/widget.png', guild_id: guild_id)
          request(route, query: params, raw: true)
        end
      end
    end
  end
end
