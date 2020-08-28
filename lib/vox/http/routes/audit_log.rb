# frozen_string_literal: true

require 'vox/http/route'
require 'vox/http/util'

module Vox
  module HTTP
    module Routes
      # HTTP methods for accessing information about a {Guild}'s {AuditLog}
      module AuditLog
        include Util

        # TODO: Is this the best place for these?
        EVENTS = {
          GUILD_UPDATE: 1,
          CHANNEL_CREATE: 10,
          CHANNEL_UPDATE: 11,
          CHANNEL_DELETE: 12,
          CHANNEL_OVERWRITE_CREATE: 13,
          CHANNEL_OVERWRITE_UPDATE: 14,
          CHANNEL_OVERWRITE_DELETE: 15,
          MEMBER_KICK: 20,
          MEMBER_PRUNE: 21,
          MEMBER_BAN_ADD: 22,
          MEMBER_BAN_REMOVE: 23,
          MEMBER_UPDATE: 24,
          MEMBER_ROLE_UPDATE: 25,
          MEMBER_MOVE: 26,
          MEMBER_DISCONNECT: 27,
          BOT_ADD: 28,
          ROLE_CREATE: 30,
          ROLE_UPDATE: 31,
          ROLE_DELETE: 32,
          INVITE_CREATE: 40,
          INVITE_UPDATE: 41,
          INVITE_DELETE: 42,
          WEBHOOK_CREATE: 50,
          WEBHOOK_UPDATE: 51,
          WEBHOOK_DELETE: 52,
          EMOJI_CREATE: 60,
          EMOJI_UPDATE: 61,
          EMOJI_DELETE: 62,
          MESSAGE_DELETE: 72,
          MESSAGE_BULK_DELETE: 73,
          MESSAGE_PIN: 74,
          MESSAGE_UNPIN: 75,
          INTEGRATION_CREATE: 80,
          INTEGRATION_UPDATE: 81,
          INTEGRATION_DELETE: 82
        }.freeze

        # Fetch a guild's audit log. [View on Discord's docs](https://discord.com/developers/docs/resources/audit-log#get-guild-audit-log)
        # @param guild_id [String, Integer] The ID of the guild to fetch audit log entries from.
        # @param user_id [String, Integer] The ID of the user to filter events for.
        # @param action_type [Symbol, Integer] The name of the audit log event to filter for. Either a key from {EVENTS}
        #   or the corresponding integer value.
        # @param before [String, Integer] The ID of the audit log entry to fetch before chronologically.
        # @param limit [Integer] The maximum amount of entries to return. Defaults to 50 if no value is supplied.
        #   Maximum of 100, minimum of 1.
        # @return [Hash<:audit_log_entries, Array<Object>>]
        # @vox.permissions VIEW_AUDIT_LOG
        # @vox.api_docs https://discord.com/developers/docs/resources/audit-log#get-guild-audit-log
        def get_guild_audit_log(guild_id, user_id: :undef, action_type: :undef, before: :undef, limit: :undef)
          route = HTTP::Route.new(:GET, '/guilds/%{guild_id}/audit-logs', guild_id: guild_id)
          query_params = filter_undef({ user_id: user_id, action_type: action_type, before: before, limit: limit })
          request(route, query: query_params)
        end
      end
    end
  end
end
