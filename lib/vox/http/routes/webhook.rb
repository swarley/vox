# frozen_string_literal: true

require 'vox/http/route'
require 'vox/http/util'

module Vox
  module HTTP
    module Routes
      # Mixin for webhook routes.
      module Webhook
        include Util

        # Create a new webhook.
        # @param channel_id [String, Integer] The ID of the channel to create this webhook in.
        # @param name [String] The name for the webhook.
        # @param avatar [UploadIO] Image for the default webhook avatar.
        # @return [Hash<Symbol, Object>] The created [webhook](https://discord.com/developers/docs/resources/webhook#webhook-object)
        #   object.
        # @vox.permissions MANAGE_WEBHOOKS
        # @vox.api_docs https://discord.com/developers/docs/resources/webhook#create-webhook
        def create_webhook(channel_id, name: :undef, avatar: :undef)
          avatar_data = if avatar != :undef && !avatar.nil?
                          "data:#{avatar.content_type};base64,#{Base64.encode64(avatar.io.read)}"
                        else
                          :undef
                        end
          json = filter_undef({ name: name, avatar: avatar_data })
          route = Route.new(:POST, '/channels/%{channel_id}/webhooks', channel_id: channel_id)
          request(route, json: json)
        end

        # Get webhooks associated with a channel.
        # @param channel_id [String, Integer] The channel to list webhooks for.
        # @return [Array<Hash<Symbol, Object>>] An array of [webhook](https://discord.com/developers/docs/resources/webhook#webhook-object)
        #   objects.
        # @vox.permissions MANAGE_WEBHOOKS
        # @vox.api_docs https://discord.com/developers/docs/resources/webhook#get-channel-webhooks
        def get_channel_webhooks(channel_id)
          request(Route.new(:GET, '/channels/%{channel_id}/webhooks', channel_id: channel_id))
        end

        # Get webhooks associated with a guild.
        # @param guild_id [String, Integer] The guild to list webhooks for.
        # @return [Array<Hash<Symbol, Object>>] An array of [webhook](https://discord.com/developers/docs/resources/webhook#webhook-object)
        #   objects.
        # @vox.permissions MANAGE_WEBHOOKS
        # @vox.api_docs https://discord.com/developers/docs/resources/webhook#get-guild-webhooks
        def get_guild_webhooks(guild_id)
          request(Route.new(:GET, '/guilds/%{guild_id}/webhooks', guild_id: guild_id))
        end

        # Get a webhook by ID.
        # @param webhook_id [String, Integer] The ID of the desired webhook.
        # @return [Hash<Symbol, Object>] The [webhook](https://discord.com/developers/docs/resources/webhook#webhook-object)
        #   object.
        # @vox.permissions MANAGE_WEBHOOKS
        # @vox.api_docs
        def get_webhook(webhook_id)
          request(Route.new(:GET, '/webhooks/%{webhook_id}', webhook_id: webhook_id))
        end

        # Get a webhook by ID and token. This does not require authentication.
        # @param webhook_id [String, Integer]
        # @param webhook_token [String]
        # @return [Hash<Symbol, Object>] The [webhook](https://discord.com/developers/docs/resources/webhook#webhook-object)
        #   object.
        # @vox.api_docs https://discord.com/developers/docs/resources/webhook#get-webhook-with-token
        def get_webhook_with_token(webhook_id, webhook_token)
          route = Route.new(:GET, '/webhooks/%{webhook_id}/%{webhook_token}',
                            webhook_id: webhook_id, webhook_token: webhook_token)
          request(route)
        end

        # Modify a webhook's properties.
        # @param webhook_id [String, Integer] The ID of the target webhook.
        # @param name [String] The new name for the webhook.
        # @param avatar [UploadIO]  The new avatar for the webhook.
        # @param channel_id [String, Integer] The new channel for this webhook to use.
        # @return [Hash<Symbol, Object>] The modified [webhook](https://discord.com/developers/docs/resources/webhook#webhook-object)
        #   object.
        # @vox.permissions MANAGE_WEBHOOKS
        # @vox.api_docs https://discord.com/developers/docs/resources/webhook#modify-webhook
        def modify_webhook(webhook_id, name: :undef, avatar: :undef, channel_id: :undef)
          avatar_data = if avatar != :undef && !avatar.nil?
                          "data:#{avatar.content_type};base64,#{Base64.encode64(avatar.io.read)}"
                        else
                          :undef
                        end
          json = filter_undef({ name: name, avatar: avatar_data, channel_id: channel_id })
          route = Route.new(:PATCH, '/webhooks/%{webhook_id}', webhook_id: webhook_id)
          request(route, json: json)
        end

        # Modify a webhook's properties with a token. This endpoint does not require authorization.
        # @param webhook_id [String, Integer] The ID of the target webhook.
        # @param webhook_token [String] The token of the target webhook.
        # @param name [String] The new name for the webhook.
        # @param avatar [UploadIO]  The new avatar for the webhook.
        # @param channel_id [String, Integer] The new channel for this webhook to use.
        # @return [Hash<Symbol, Object>] The modified [webhook](https://discord.com/developers/docs/resources/webhook#webhook-object)
        #   object.
        # @vox.api_docs https://discord.com/developers/docs/resources/webhook#modify-webhook-with-token
        def modify_webhook_with_token(webhook_id, webhook_token, name: :undef, avatar: :undef, channel_id: :undef)
          avatar_data = if avatar != :undef && !avatar.nil?
                          "data:#{avatar.content_type};base64,#{Base64.encode64(avatar.io.read)}"
                        else
                          :undef
                        end
          json = filter_undef({ name: name, avatar: avatar_data, channel_id: channel_id })
          route = Route.new(:PATCH, '/webhooks/%{webhook_id}/%{webhook_token}',
                            webhook_id: webhook_id, webhook_token: webhook_token)
          request(route, json: json)
        end

        # Delete a webhook.
        # @param webhook_id [String, Integer] The ID of the webhook to be deleted.
        # @return [nil] Returns `nil` on success.
        # @vox.permissions MANAGE_WEBHOOKS
        # @vox.api_docs https://discord.com/developers/docs/resources/webhook#delete-webhook
        def delete_webhook(webhook_id)
          request(Route.new(:DELETE, '/webhooks/%{webhook_id}', webhook_id: webhook_id))
        end

        # Delete a webhook with a token. This endpoint does not require authorization.
        # @param webhook_id [String, Integer] The ID of the webhook to be deleted.
        # @param webhook_token [String] The token for the target webhook/
        # @return [nil] Returns `nil` on success.
        # @vox.api_docs https://discord.com/developers/docs/resources/webhook#delete-webhook-with-token
        def delete_webhook_with_token(webhook_id, webhook_token)
          route = Route.new(:DELETE, '/webhooks/%{webhook_id}/%{webhook_token}',
                            webhook_id: webhook_id, webhook_token: webhook_token)
          request(route)
        end

        # Post content to a webhook.
        # @param webhook_id [String, Integer] The ID of the webhook to post to.
        # @param webhook_token [String] The token for the target webhook.
        # @param wait [true, false] Waits for server confirmation of message send before response,
        #   and returns the created message body.
        # @param content [String] The message contents.
        # @param username [String] Override the default avatar of the webhook.
        # @param avatar_url [String] Override the default avatar of the webhook.
        # @param tts [true, false] If this message is TTS.
        # @param file [UploadIO] The file being sent.
        # @param embeds [Array<Hash<Symbol, Object>>] An array of up to 10 [embed](https://discord.com/developers/docs/resources/channel#embed-object)
        #   objects.
        # @param allowed_mentions [Hash<Symbol, Object>] [Allowed mentions](https://discord.com/developers/docs/resources/channel#allowed-mentions-object)
        #   object for this message.
        # @param attachments [Hash<String, UploadIO>, Array<UploadIO>] A hash in the form of `filename => upload_io` to
        #   be referenced in embeds via the `attachment://` URI, or an array of {UploadIO} who's filenames are derived
        #   from the existing UploadIO object. See [attachment:// docs](https://discord.com/developers/docs/resources/channel#create-message-using-attachments-within-embeds).
        # @vox.api_docs https://discord.com/developers/docs/resources/webhook#execute-webhook
        def execute_webhook(webhook_id, webhook_token, wait: :undef, content: :undef, username: :undef,
                            avatar_url: :undef, tts: :undef, file: :undef, embeds: :undef,
                            allowed_mentions: :undef, attachments: :undef)
          params = filter_undef({ wait: wait })
          json = filter_undef({ content: content, username: username, avatar_url: avatar_url, tts: tts, embeds: embeds,
                                allowed_mentions: allowed_mentions })
          route = Route.new(:POST, '/webhooks/%{webhook_id}/%{webhook_token}',
                            webhook_id: webhook_id, webhook_token: webhook_token)

          if file != :undef
            data = { file: file, payload_json: MultiJson.dump(json) }
            request(route, data: data, query: params)
          elsif attachments != :undef
            attachments = attachments.collect { |k, v| UploadIO.new(v.io, v.content_type, k) } if attachments.is_a? Hash
            attach_hash = Array(0...attachments.size).zip(attachments).to_h
            data = attach_hash.merge(payload_json: MultiJson.dump(json))
            request(route, data: data, query: params)
          else
            request(route, json: json, query: params)
          end
        end
      end
    end
  end
end
