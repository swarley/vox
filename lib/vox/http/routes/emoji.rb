# frozen_string_literal: true

require 'base64'
require 'vox/http/route'
require 'vox/http/util'

module Vox
  module HTTP
    module Routes
      # Mixin for emoji routes.
      module Emoji
        include Util

        # Fetch a list of emojis for a given guild.
        # @param guild_id [String, Integer] The ID of the guild this emoji belongs to.
        # @return [Array<Hash<Symbol, Object>>] An array of [emoji](https://discord.com/developers/docs/resources/emoji#emoji-object)
        #   objects.
        # @vox.api_docs https://discord.com/developers/docs/resources/emoji#list-guild-emojis
        def list_guild_emojis(guild_id)
          route = Route.new(:GET, '/guilds/%{guild_id}/emojis', guild_id: guild_id)
          request(route)
        end

        # Get an emoji object by ID.
        # @param guild_id [String, Integer] The ID of the guild this emoji belongs to.
        # @param emoji_id [String, Integer] The ID of the desired emoji.
        # @return [Hash<Symbol, Object>] An [emoji](https://discord.com/developers/docs/resources/emoji#emoji-object)
        #   object.
        # @vox.api_docs https://discord.com/developers/docs/resources/emoji#get-guild-emoji
        def get_guild_emoji(guild_id, emoji_id)
          route = Route.new(:GET, '/guilds/%{guild_id}/emojis/%{emoji_id}', guild_id: guild_id, emoji_id: emoji_id)
          request(route)
        end

        # Create an emoji in a target guild.
        # @param guild_id [String, Integer] The ID of the guild to create an emoji in.
        # @param image [UploadIO] {UploadIO} for the emoji image. Can be up to 256kb in size.
        # @param name [String] The name for the emoji.
        # @param roles [Array<String, Integer>] Roles for which the emoji will be whitelisted.
        # @return [Hash<Symbol, Object>] An [emoji](https://discord.com/developers/docs/resources/emoji#emoji-object)
        #   object.
        # @note Attempting to upload an emoji image larger than 256kb will result in a {Error::BadRequest} with
        #   no JSON status code.
        # @vox.permissions MANAGE_EMOJIS
        # @vox.api_docs https://discord.com/developers/docs/resources/emoji#create-guild-emoji
        def create_guild_emoji(guild_id, image:, name: :undef, roles: :undef)
          image_data = image.io.read
          json = filter_undef({ name: name, roles: roles,
                                image: "data:#{image.content_type};base64,#{Base64.encode64(image_data)}" })

          route = Route.new(:POST, '/guilds/%{guild_id}/emojis', guild_id: guild_id)
          request(route, json: json)
        end

        # Modify a guild emoji.
        # @param guild_id [String, Integer] The ID of the guild the emoji is in.
        # @param emoji_id [String, Integer] The ID of the target emoji.
        # @param name [String] The name for the emoji.
        # @param roles [Array<String, Integer>] Roles for which the emoji will be whitelisted.
        # @param reason [String] The reason this emoji is being modified.
        # @return [Hash<Symbol, Object>] The updated [emoji](https://discord.com/developers/docs/resources/emoji#emoji-object)
        #   object.
        # @vox.permissions MANAGE_EMOJIS
        # @vox.api_docs https://discord.com/developers/docs/resources/emoji#modify-guild-emoji
        def modify_guild_emoji(guild_id, emoji_id, name: :undef, roles: :undef, reason: nil)
          json = filter_undef({ name: name, roles: roles })
          route = Route.new(:PATCH, '/guilds/%{guild_id}/emojis/%{emoji_id}',
                            guild_id: guild_id, emoji_id: emoji_id)
          request(route, json: json, reason: reason)
        end

        # Delete an emoji by its ID.
        # @param guild_id [String, Integer] The ID of the guild that owns this emoji.
        # @param emoji_id [String, Integer] The ID of the emoji to be deleted.
        # @param reason [String] The reason this emoji is being deleted.
        # @return [nil] Returns `nil` on success.
        # @vox.permissions MANAGE_EMOJIS
        # @vox.api_docs https://discord.com/developers/docs/resources/emoji#delete-guild-emoji
        def delete_guild_emoji(guild_id, emoji_id, reason: nil)
          route = Route.new(:DELETE, '/guilds/%{guild_id}/emojis/%{emoji_id}',
                            guild_id: guild_id, emoji_id: emoji_id)
          request(route, reason: reason)
        end
      end
    end
  end
end
