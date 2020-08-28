# frozen_string_literal: true

require 'vex/http/routes/audit_log'
require 'vex/http/routes/channel'
require 'vex/http/routes/emoji'
require 'vex/http/routes/guild'
require 'vex/http/routes/invite'
require 'vex/http/routes/user'
require 'vex/http/routes/voice'
require 'vex/http/routes/webhook'

module Vex
  module HTTP
    # Module that contains all route containers.
    module Routes
      # Include all route containers if this module is included
      def self.included(klass)
        [AuditLog, Channel, Emoji, Guild, Invite, User, Voice, Webhook].each { |m| klass.include m }
      end
    end
  end
end
