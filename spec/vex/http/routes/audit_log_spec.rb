# frozen_string_literal: true

require 'rspec'
require 'vex/http/routes/audit_log'

RSpec.describe Vex::HTTP::Routes::AuditLog do
  let(:client) { Class.new { include Vex::HTTP::Routes::AuditLog }.new }
  let(:guild_id) { 12_345 }

  before do
    stub_const('Route', Vex::HTTP::Route)
    allow(client).to receive(:request).with(instance_of(Route), query: anything)
  end

  describe '#get_guild_audit_log' do
    let(:route) { Route.new(:GET, '/guilds/%{guild_id}/audit-logs', guild_id: guild_id) }

    context 'when no arguments are given' do
      it 'does not pass query params' do
        client.get_guild_audit_log(guild_id)

        expect(client).to have_received(:request).with(route, query: {})
      end
    end

    context 'when arguments are given' do
      it 'passes them as query string parameters' do
        client.get_guild_audit_log(guild_id, limit: 1)

        expect(client).to have_received(:request).with(route, query: { limit: 1 })
      end
    end
  end
end
