# frozen_string_literal: true

require 'vex/http/route'
require 'vex/http/util'

module Vex
  module HTTP
    module Routes
      # Mixin for /channel/ routes.
      module Channel
        # Channel types.
        TYPES = {
          GUILD_TEXT: 0,
          DM: 1,
          GUILD_VOICE: 2,
          GROUP_DM: 3,
          GUILD_CATEGORY: 4,
          GUILD_NEWS: 5,
          GUILD_STORE: 6
        }.freeze

        include Util

        # Get a channel by ID.
        # @param channel_id [String, Integer] ID of the desired channel.
        # @return [Hash<Symbol, Object>] A [channel](https://discord.com/developers/docs/resources/channel#channel-object)
        #   object.
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#get-channel
        def get_channel(channel_id)
          request(Route.new(:GET, '/channels/%{channel_id}', channel_id: channel_id))
        end

        # Update a channel's settings. Parameters other than `channel_id` are all optional.
        # @param name [String] Channel name, must be between 2-100 characters.
        # @param type [Integer] Channel type, only switching between `GUILD_TEXT` and `GUILD_NEWS`
        #   is supported on guilds which have the `NEWS` feature.
        # @param position [Integer, nil] The position of the channel in the listing.
        # @param topic [String, nil] Channel topic, must be between 0-1024 characters. Only usable in `GUILD_TEXT`
        #   and `GUILD_NEWS` channels.
        # @param nsfw [true, false, nil] Whether the channel is not safe for work. Only usable on
        #   `GUILD_TEXT`, `GUILD_NEWS`, and `GUILD_STORE` channels.
        # @param rate_limit_per_user [Integer, nil] The amount of seconds a user has to wait between sending
        #   messages. This value can be between 0-21600 seconds. Users and bots with `MANAGE_MESSAGES`
        #   or `MANAGE_CHANNEL` are unaffected by this limit. Only usable in `GUILD_TEXT` channels.
        # @param bitrate [Integer, nil] The bitrate of a `GUILD_VOICE` channel. Between 8000 and 96000, or
        #   128000 for VIP servers.
        # @param user_limit [Integer, nil] The maximum amount of users allowed in a voice channel. 0 is no limit,
        #   and limiting values can be between 1-99.
        # @param permission_overwrites [Array<Overwrite, Hash>] Channel or category specific permissions.
        # @param parent_id [String, Integer] The ID of the new parent category for a channel. Only usable in
        #   `GUILD_TEXT`, `GUILD_NEWS`, `GUILD_STORE`, and `GUILD_VOICE` channels.
        # @param reason [String, nil] The reason for modifying the channel.
        # @return [Hash<Symbol, Object>] A [channel](https://discord.com/developers/docs/resources/channel#channel-object)
        #   object.
        # @note Fires a channel update. In the event of modifying a category, individual
        #   channel updates will fire for each child that is also modified.
        # @vex.permissions MANAGE_CHANNELS
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#modify-channel
        def modify_channel(channel_id, name: :undef, type: :undef, position: :undef,
                           topic: :undef, nsfw: :undef, rate_limit_per_user: :undef,
                           bitrate: :undef, user_limit: :undef,
                           permission_overwrites: :undef, parent_id: :undef, reason: nil)
          json = filter_undef({
                                name: name, type: type, position: position, topic: topic, nsfw: nsfw,
                                rate_limit_per_user: rate_limit_per_user, bitrate: bitrate,
                                user_limit: user_limit, permission_overwrites: permission_overwrites,
                                parent_id: parent_id
                              })
          route = Route.new(:PATCH, '/channels/%{channel_id}', channel_id: channel_id)
          request(route, json: json, reason: reason)
        end

        # Delete a channel by ID, or close a private message.
        # @param channel_id [String, Integer] The ID of the channel to be deleted.
        # @param reason [String, nil] The reason the channel is being deleted.
        # @return [Hash<Symbol, Object>] The [channel](https://discord.com/developers/docs/resources/channel#channel-object)
        #   object of the deleted channel.
        # @note Fires a channel delete event.
        # @note Deleting a category will not delete its children, each child will have
        #   its `parent_id` field removed and a channel update will be fired for each
        #   of them.
        # @vex.permissions MANAGE_CHANNELS
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#deleteclose-channel
        def delete_channel(channel_id, reason: nil)
          route = Route.new(:DELETE, '/channels/%{channel_id}', channel_id: channel_id)
          request(route, reason: reason)
        end

        # Get messages from a channel, by channel ID. All parameters other than `channel_id` are
        # optional.
        # @param channel_id [String, Integer] The ID of the channel where the messages
        #   are being fetched from.
        # @param around [String, Integer] Retreive messages around this ID.
        # @param before [String, Integer] Retreive messages before this ID.
        # @param after [String, Integer] Retreive messages after this ID.
        # @param limit [Integer] Maximum number of messages to return. Can be between 1-100.
        # @return [Array<Hash<Symbol, Object>>] [Message](https://discord.com/developers/docs/resources/channel#message-object)
        #   objects returned from the channel history.
        # @note If you lack the `READ_MESSAGE_HISTORY` permission in the desired channel this
        #   will return no messages.
        # @vex.permissions VIEW_CHANNEL
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#get-channel-messages
        def get_channel_messages(channel_id, around: :undef, before: :undef, after: :undef, limit: :undef)
          route = Route.new(:GET, '/channels/%{channel_id}/messages', channel_id: channel_id)
          params = filter_undef({ around: around, before: before, after: after, limit: limit })
          request(route, query: params)
        end

        # Get a specific message from a channel by ID.
        # @param channel_id [String, Integer] The ID of the channel containing the desired message.
        # @param message_id [String, Integer] The ID of the desired message.
        # @return [Hash<Symbol, Object>] The [message](https://discord.com/developers/docs/resources/channel#message-object)
        #   object.
        # @note In guild channels the `READ_MESSAGE_HISTORY` permission is requred.
        # @vex.permissions READ_MESSAGE_HISTORY
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#get-channel-message
        def get_channel_message(channel_id, message_id)
          route = Route.new(:GET, '/channels/%{channel_id}/messages/%{message_id}',
                            channel_id: channel_id, message_id: message_id)
          request(route)
        end

        # Create a message in a channel. All parameters other than `channel_id` are optional.
        # @param channel_id [String, Integer] The ID of the target channel.
        # @param content [String] Message contents, up to 2000 characters.
        # @param nonce [String, Integer] A nonce used for optimistic message sending.
        # @param tts [true, false] Whether this message should use TTS (text to speech).
        # @param file [File, String] A File object, or path to a file, to be uploaded.
        # @param embed [Hash] Embedded rich content. See [embed object](https://discord.com/developers/docs/resources/channel#embed-object).
        # @param allowed_mentions [Hash<(:parse, :roles, :users), Array<:roles, :users, :everyone>>] Rules for what
        #   mentions are allowed in the message. See [allowed_mentions object](https://discord.com/developers/docs/resources/channel#allowed-mentions-object).
        # @param attachments [Hash<String, UploadIO>, Array<UploadIO>] A hash in the form of `filename => upload_io` to
        #   be referenced in embeds via the `attachment://` URI, or an array of {UploadIO} who's filenames are derived
        #   from the existing UploadIO object. See [attachment:// docs](https://discord.com/developers/docs/resources/channel#create-message-using-attachments-within-embeds).
        # @return [Hash<Symbol, Object>] The created [message](https://discord.com/developers/docs/resources/channel#message-object)
        #   object.
        # @note You must send one of `content`, `embed`, or `file`.
        # @note If `tts` is set to `true`, you also require the `SEND_TTS_MESSAGES` permission.
        # @vex.permissions SEND_MESSAGES SEND_TTS_MESSAGES
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#create-message
        def create_message(channel_id, content: :undef, nonce: :undef, tts: :undef, file: :undef, embed: :undef,
                           allowed_mentions: :undef, attachments: :undef)
          route = Route.new(:POST, '/channels/%{channel_id}/messages', channel_id: channel_id)
          json = filter_undef({ content: content, nonce: nonce, tts: tts, embed: embed,
                                allowed_mentions: allowed_mentions })

          if file != :undef
            data = { file: file, payload_json: MultiJson.dump(json) }
            request(route, data: data)
          elsif attachments != :undef
            attachments = attachments.collect { |k, v| UploadIO.new(v.io, v.content_type, k) } if attachments.is_a? Hash
            attach_hash = Array(0...attachments.size).zip(attachments).to_h
            data = attach_hash.merge({ payload_json: MultiJson.dump(json) })
            request(route, data: data)
          else
            request(route, json: json)
          end
        end

        # Create a reaction on a message.
        # @param channel_id [String, Integer] The ID of the channel that contains the target message.
        # @param message_id [String, Integer] The ID of the target message.
        # @param emoji [String] Either a unicode emoji, or Discord emoji in the format of `name:id`.
        # @note Requires `READ_MESSAGE_HISTORY`, and `ADD_REACTIONS` if no other user has reacted with
        #   the emoji.
        # @note If your emoji is in the wrong format you will receive error code `10014: Unknown Emoji`
        # @note If the emoji name is unknown, you can provide any alphanumeric value as a placeholder.
        # @vex.permissions READ_MESSAGE_HISTORY ADD_REACTIONS
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#create-reaction
        def create_reaction(channel_id, message_id, emoji)
          escaped_emoji = URI.encode_www_form_component(emoji)
          route = Route.new(:PUT, '/channels/%{channel_id}/messages/%{message_id}/reactions/%{emoji}/@me',
                            channel_id: channel_id, message_id: message_id, emoji: escaped_emoji)
          request(route)
        end

        # Delete a reaction from the current user on a message.
        # @param channel_id [String, Integer] The ID of the channel that contains the target message.
        # @param message_id [String, Integer] The ID of the target message.
        # @param emoji [String] Either a unicode emoji, or Discord emoji in the format of `name:id`.
        # @note If your emoji is in the wrong format you will receive error code `10014: Unknown Emoji`
        # @note If the emoji name is unknown, you can provide any alphanumeric value as a placeholder.
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#delete-own-reaction
        def delete_own_reaction(channel_id, message_id, emoji)
          escaped_emoji = URI.encode_www_form_component(emoji)
          route = Route.new(:DELETE, '/channels/%{channel_id}/messages/%{message_id}/reactions/%{emoji}/@me',
                            channel_id: channel_id, message_id: message_id, emoji: escaped_emoji)
          request(route)
        end

        # Delete a reaction from a user on a message.
        # @param channel_id [String, Integer] The ID of the channel that contains the target message.
        # @param message_id [String, Integer] The ID of the target message.
        # @param emoji [String] Either a unicode emoji, or Discord emoji in the format of `name:id`.
        # @param user_id [String, Integer] The ID of the user to delete the reaction for.
        # @vex.permissions MANAGE_MESSAGES
        # @note If your emoji is in the wrong format you will receive error code `10014: Unknown Emoji`
        # @note If the emoji name is unknown, you can provide any alphanumeric value as a placeholder.
        # @vex.permissions MANAGE_MESSAGES
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#delete-user-reaction
        def delete_user_reaction(channel_id, message_id, emoji, user_id)
          escaped_emoji = URI.encode_www_form_component(emoji)
          route = Route.new(:DELETE, '/channels/%{channel_id}/messages/%{message_id}/reactions/%{emoji}/%{user_id}',
                            channel_id: channel_id, message_id: message_id, emoji: escaped_emoji, user_id: user_id)
          request(route)
        end

        # Get a list of users that have reacted with a specific emoji.
        # @param channel_id [String, Integer] The ID of the channel that contains the target message.
        # @param message_id [String, Integer] The ID of the target message.
        # @param emoji [String] Either a unicode emoji, or Discord emoji in the format of `name:id`.
        # @param before [String, Integer] Retreive users before this ID.
        # @param after [String, Integer] Retreive users after this ID.
        # @param limit [Integer] The maximum number of users to receive. Between 1-100.
        # @note If your emoji is in the wrong format you will receive error code `10014: Unknown Emoji`
        # @note If the emoji name is unknown, you can provide any alphanumeric value as a placeholder.
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#get-reactions
        def get_reactions(channel_id, message_id, emoji, before: :undef, after: :undef, limit: :undef)
          escaped_emoji = URI.encode_www_form_component(emoji)
          params = filter_undef({ before: before, after: after, limit: limit })
          route = Route.new(:GET, '/channels/%{channel_id}/messages/%{message_id}/reactions/%{emoji}',
                            channel_id: channel_id, message_id: message_id, emoji: escaped_emoji)
          request(route, query: params)
        end

        # Delete all reactions on a message.
        # @param channel_id [String, Integer] The ID of the channel that contains the target message.
        # @param message_id [String, Integer] The ID of the target message.
        # @vex.permissions MANAGE_MESSAGES
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#delete-all-reactions
        def delete_all_reactions(channel_id, message_id)
          route = Route.new(:DELETE, '/channels/%{channel_id}/messages/%{message_id}/reactions',
                            channel_id: channel_id, message_id: message_id)
          request(route)
        end

        # Delete all reactions of a specific emoji on a message.
        # @param channel_id [String, Integer] The ID of the channel that contains the target message.
        # @param message_id [String, Integer] The ID of the target message.
        # @param emoji [String] Either a unicode emoji, or Discord emoji in the format of `name:id`.
        # @note If your emoji is in the wrong format you will receive error code `10014: Unknown Emoji`
        # @note If the emoji name is unknown, you can provide any alphanumeric value as a placeholder.
        # @vex.permissions MANAGE_MESSAGES
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#delete-all-reactions-for-emoji
        def delete_all_reactions_for_emoji(channel_id, message_id, emoji)
          escaped_emoji = URI.encode_www_form_component(emoji)
          route = Route.new(:DELETE, '/channels/%{channel_id}/messages/%{message_id}/reactions/%{emoji}',
                            channel_id: channel_id, message_id: message_id, emoji: escaped_emoji)
          request(route)
        end

        # Edit a previously sent message. All parameters other than `channel_id` and `message_id`
        # are optional and nullable.
        # @param channel_id [String, Integer] The ID of the channel that contains the target message.
        # @param message_id [String, Integer] The ID of the target message.
        # @param content [String, nil] The message content. If `nil`, existing content will be removed.
        # @param embed [Hash] Embedded rich content. If `nil`, the existing embed will be removed.
        # @param flags [Integer] Message flags. If `nil`, the existing flags will be removed. When setting flags be sure
        #   to include all previously set flags in addition to the ones you are modifying.
        #   See [message flags](https://discord.com/developers/docs/resources/channel#message-object-message-flags).
        # @note You can only edit the flags of a message not sent by the current user, and only if the current
        #   user has `MANAGE_MESSAGES` permissions.
        # @vex.permissions MANAGE_MESSAGES (if editing the flags of a message not sent by the current user)
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#edit-message
        def edit_message(channel_id, message_id, content: :undef, embed: :undef, flags: :undef)
          route = Route.new(:PATCH, '/channels/%{channel_id}/messages/%{message_id}',
                            channel_id: channel_id, message_id: message_id)
          json = filter_undef({ content: content, embed: embed, flags: flags })
          request(route, json: json)
        end

        # Delete a previously sent message.
        # @param channel_id [String, Integer] The ID of the channel that contains the target message.
        # @param message_id [String, Integer] The ID of the target message.
        # @param reason [String] The reason for deleting this message.
        # @vex.permissions MANAGE_MESSAGES (if not the message was not sent by the current user)
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#delete-message
        def delete_message(channel_id, message_id, reason: nil)
          route = Route.new(:DELETE, '/channels/%{channel_id}/messages/%{message_id}',
                            channel_id: channel_id, message_id: message_id)
          request(route, reason: reason)
        end

        # Delete multiple message in a single request.
        # @param channel_id [String, Integer] The ID of the channel that contains the target messages.
        # @param messages [Array<String, Integer>] The IDs of the target messages.
        # @param reason [String] The reason the messages are being deleted.
        # @note The endpoint will not delete messages older than 2 weeks and will fail with {HTTP::Error::BadRequest}
        #   if any message provided is older than that, or a duplicate within the list of message IDs.
        # @vex.permissions MANAGE_MESSAGES
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#bulk-delete-messages
        def bulk_delete_messages(channel_id, messages, reason: nil)
          route = Route.new(:POST, '/channels/%{channel_id}/messages/bulk-delete', channel_id: channel_id)
          request(route, json: { messages: messages }, reason: reason)
        end

        # Edit the channel permission overwrites for a user or role in a channel.
        # @param channel_id [String, Integer] The ID of the channel that contains the target overwrite.
        # @param overwrite_id [String, Integer] The ID of the target user or role.
        # @param allow [Integer] Bitwise value of all allowed permissions.
        # @param deny [Integer] Bitwise value of all denied permissions.
        # @param type [:member, :role]
        # @note Only usable for guild channels.
        # @vex.permissions MANAGE_ROLES
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#edit-channel-permissions
        def edit_channel_permissions(channel_id, overwrite_id, allow:, deny:, type:, reason: nil)
          route = Route.new(:PUT, '/channels/%{channel_id}/permissions/%{overwrite_id}',
                            channel_id: channel_id, overwrite_id: overwrite_id)
          json = { allow: allow, deny: deny, type: type }
          request(route, json: json, reason: reason)
        end

        # Get a list of invites (with invite metadata) for a channel.
        # @param channel_id [String, Integer] The ID of the target channel.
        # @return [Array<Hash<Symbol, Object>>] An array of [invite objects](https://discord.com/developers/docs/resources/invite#invite-object-invite-structure)
        #   with [invite metadata](https://discord.com/developers/docs/resources/invite#invite-metadata-object-invite-metadata-structure).
        # @vex.permissions MANAGE_CHANNELS
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#get-channel-invites
        def get_channel_invites(channel_id)
          route = Route.new(:GET, '/channels/%{channel_id}/invites', channel_id: channel_id)
          request(route)
        end

        # Create a new invite for a channel. All parameters aside from `channel_id` are optional.
        # @param channel_id [String, Integer] The ID of the channel to create an invite in.
        # @param max_age [Integer] Duration of invite in seconds before expiry, or 0 for never. Defaults to 24 hours.
        # @param max_uses [Integer] Maximum number of uses, or 0 for unlimited uses. Defaults to 0.
        # @param temporary [true, false] Whether this invite only grants temporary membership. Defaults to false.
        # @param unique [true, false] Whether or not to avoid using an existing similar invite. Defaults to false.
        # @param target_user [String, Integer] The ID of the user intended for this invite.
        # @param target_user_type [Integer] The [target user type](https://discord.com/developers/docs/resources/invite#invite-object-target-user-types)
        #   of this invite.
        # @param reason [String] The reason for creating this invite.
        # @return [Hash<Symbol, Object>] The created [invite object](https://discord.com/developers/docs/resources/invite#invite-object-invite-structure).
        # @vex.permissions CREATE_INSTANT_INVITE
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#create-channel-invite
        def create_channel_invite(channel_id, max_age: :undef, max_uses: :undef, temporary: :undef, unique: :undef,
                                  target_user: :undef, target_user_type: :undef, reason: nil)
          route = Route.new(:POST, '/channels/%{channel_id}/invites', channel_id: channel_id)
          json = filter_undef({ max_age: max_age, max_uses: max_uses, temporary: temporary, unique: unique,
                                target_user: target_user, target_user_type: target_user_type })
          request(route, json: json, reason: reason)
        end

        # Delete a channel permission overwrite for a user or role in a channel.
        # @param channel_id [String, Integer] The ID of the channel that contains the target overwrite.
        # @param overwrite_id [String, Integer] The ID of the target user or role.
        # @param reason [String] The reason this overwrite is being deleted.
        # @note Only usable within guild channels.
        # @vex.permissions MANAGE_ROLES
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#delete-channel-permission
        def delete_channel_permission(channel_id, overwrite_id, reason: nil)
          route = Route.new(:DELETE, '/channels/%{channel_id}/permissions/%{overwrite_id}',
                            channel_id: channel_id, overwrite_id: overwrite_id)
          request(route, reason: reason)
        end

        # Post a typing indicator for a channel.
        # @param channel_id [String, Integer] The ID of the channel to appear as typing in.
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#trigger-typing-indicator
        def trigger_typing_indicator(channel_id)
          route = Route.new(:POST, '/channels/%{channel_id}/typing', channel_id: channel_id)
          request(route)
        end

        # Get all pinned messages in a channel.
        # @param channel_id [String, Integer] The ID of the channel to fetch the pins of.
        # @return [Array<Hash<Symbol, Object>>] An array of pinned [message objects](https://discord.com/developers/docs/resources/channel#message-object).
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#get-pinned-messages
        def get_pinned_messages(channel_id)
          route = Route.new(:GET, '/channels/%{channel_id}/pins', channel_id: channel_id)
          request(route)
        end

        # Add a message to a channel's pins.
        # @param channel_id [String, Integer] The ID of the channel to add a pinned message to.
        # @param message_id [String, Integer] The ID of the message to pin.
        # @param reason [String] The reason a message is being pinned.
        # @vex.permissions MANAGE_MESSAGES
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#add-pinned-channel-message
        def add_pinned_channel_message(channel_id, message_id, reason: nil)
          route = Route.new(:POST, '/channels/%{channel_id}/pins/%{message_id}',
                            channel_id: channel_id, message_id: message_id)
          request(route, reason: reason)
        end

        # Remove a message from a channel's pins.
        # @param channel_id [String, Integer] The ID of the channel to remove a pinned message from.
        # @param message_id [String, Integer] The ID of the message to unpin.
        # @param reason [String] The reason a message is being unpinned.
        # @vex.permissions MANAGE_MESSAGES
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#delete-pinned-channel-message
        def delete_pinned_channel_message(channel_id, message_id, reason: nil)
          route = Route.new(:DELETE, '/channels/%{channel_id}/pins/%{message_id}',
                            channel_id: channel_id, message_id: message_id)
          request(route, reason: reason)
        end

        # Add a recipient to a group DM using their access token.
        # @param channel_id [String, Integer] The ID of the group DM to add the user to.
        # @param user_id [String, Integer] The ID of the user to add.
        # @param access_token [String] The access token of a user that has granted your app
        #   the `gdm.join` scope.
        # @param nick [String] The nickname of the user being added.
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#group-dm-add-recipient
        def group_dm_add_recipient(channel_id, user_id, access_token:, nick: :undef)
          route = Route.new(:PUT, '/channels/%{channel_id}/recipients/%{user_id}',
                            channel_id: channel_id, user_id: user_id)
          json = filter_undef({ access_token: access_token, nick: nick })
          request(route, json: json)
        end

        # Remove a recipient from a group DM.
        # @param channel_id [String, Integer] The ID of the channel the user is being removed from.
        # @param user_id [String, Integer] The ID of the user being removed from the group DM.
        # @vex.api_docs https://discord.com/developers/docs/resources/channel#group-dm-remove-recipient
        def group_dm_remove_recipient(channel_id, user_id)
          route = Route.new(:DELETE, '/channels/%{channel_id}/recipients/%{user_id}',
                            channel_id: channel_id, user_id: user_id)
          request(route)
        end
      end
    end
  end
end
