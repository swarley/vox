# frozen_string_literal: true

require 'rspec'

require 'vex/http/routes/user'

RSpec.describe Vex::HTTP::Routes::Guild do
  let(:client) { Class.new { include Vex::HTTP::Routes::Guild }.new }
  let(:id) { 'id' }
  let(:integration_id) { 'integration_id' }
  let(:role_id) { 'role_id' }
  let(:user_id) { 'user_id' }
  let(:channel_id) { 'channel_id' }
  let(:token) { 'token' }
  let(:reason) { instance_double('String') }

  before do
    stub_const('Route', Vex::HTTP::Route)
    allow(client).to receive(:request).with(any_args)
  end

  describe '#create_guild' do
    it 'makes a request with json parameters' do
      client.create_guild(name: 'name')
      route = Route.new(:POST, '/guilds')
      expect(client).to have_received(:request).with(route, json: { name: 'name' })
    end
  end

  describe '#get_guild_preview' do
    it 'makes a request with no parameters' do
      client.get_guild_preview(id)
      route = Route.new(:GET, '/guilds/%{guild_id}/preview', guild_id: id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#modify_guild' do
    it 'make a request with json parameters' do
      client.modify_guild(id, name: 'foo', reason: reason)
      route = Route.new(:PATCH, '/guilds/%{guild_id}', guild_id: id)
      expect(client).to have_received(:request).with(route, json: { name: 'foo' }, reason: reason)
    end
  end

  describe '#delete_guild' do
    it 'makes a request with no parameters' do
      client.delete_guild(id)
      route = Route.new(:DELETE, '/guilds/%{guild_id}', guild_id: id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#get_guild_channels' do
    it 'makes a request with no parameters' do
      client.get_guild_channels(id)
      route = Route.new(:GET, '/guilds/%{guild_id}/channels', guild_id: id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#create_guild_channel' do
    it 'makes a request with json parameters' do
      client.create_guild_channel(id, name: 'foo', reason: reason)
      route = Route.new(:POST, '/guilds/%{guild_id}/channels', guild_id: id)
      expect(client).to have_received(:request).with(route, json: { name: 'foo' }, reason: reason)
    end
  end

  describe '#modify_guild_channel_positions' do
    it 'makes a request with json parameters' do
      client.modify_guild_channel_positions(id, [], reason: reason)
      route = Route.new(:PATCH, '/guilds/%{guild_id}/channels', guild_id: id)
      expect(client).to have_received(:request).with(route, json: [], reason: reason)
    end
  end

  describe '#get_guild_member' do
    it 'makes a request with no parameters' do
      client.get_guild_member(id, user_id)
      route = Route.new(:GET, '/guilds/%{guild_id}/members/%{user_id}',
                        guild_id: id, user_id: user_id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#list_guild_members' do
    it 'makes a request with query parameters' do
      client.list_guild_members(id, limit: 5)
      route = Route.new(:GET, '/guilds/%{guild_id}/members', guild_id: id)
      expect(client).to have_received(:request).with(route, query: { limit: 5 })
    end
  end

  describe '#add_guild_member' do
    it 'makes a request with json parameters' do
      client.add_guild_member(id, user_id, access_token: 'token', nick: 'nick')
      route = Route.new(:PUT, '/guilds/%{guild_id}/members/%{user_id}',
                        guild_id: id, user_id: user_id)
      expect(client).to have_received(:request).with(route, json: { access_token: 'token', nick: 'nick' })
    end
  end

  describe '#modify_guild_member' do
    it 'makes a request with json parameters' do
      client.modify_guild_member(id, user_id, nick: 'nick', reason: reason)
      route = Route.new(:PATCH, '/guilds/%{guild_id}/members/%{user_id}',
                        guild_id: id, user_id: user_id)
      expect(client).to have_received(:request).with(route, json: { nick: 'nick' }, reason: reason)
    end
  end

  describe '#modify_current_user_nick' do
    it 'makes a request with json parameters' do
      client.modify_current_user_nick(id, nick: 'nick', reason: reason)
      route = Route.new(:PATCH, '/guilds/%{guild_id}/members/@me/nick', guild_id: id)
      expect(client).to have_received(:request).with(route, json: { nick: 'nick' }, reason: reason)
    end
  end

  describe '#add_guild_member_role' do
    it 'makes a request with no parameters' do
      client.add_guild_member_role(id, user_id, role_id, reason: reason)
      route = Route.new(:PUT, '/guilds/%{guild_id}/members/%{user_id}/roles/%{role_id}',
                        guild_id: id, user_id: user_id, role_id: role_id)
      expect(client).to have_received(:request).with(route, reason: reason)
    end
  end

  describe '#remove_guild_member_role' do
    it 'makes a request with no parameters' do
      client.remove_guild_member_role(id, user_id, role_id, reason: reason)
      route = Route.new(:DELETE, '/guilds/%{guild_id}/members/%{user_id}/roles/%{role_id}',
                        guild_id: id, user_id: user_id, role_id: role_id)
      expect(client).to have_received(:request).with(route, reason: reason)
    end
  end

  describe '#remove_guild_member' do
    it 'makes a request with no parameters' do
      client.remove_guild_member(id, user_id, reason: reason)
      route = Route.new(:DELETE, '/guilds/%{guild_id}/members/%{user_id}',
                        guild_id: id, user_id: user_id)
      expect(client).to have_received(:request).with(route, reason: reason)
    end
  end

  describe '#get_guild_bans' do
    it 'makes a request with no parameters' do
      client.get_guild_bans(id)
      route = Route.new(:GET, '/guilds/%{guild_id}/bans', guild_id: id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#get_guild_ban' do
    it 'makes a request with no parameters' do
      client.get_guild_ban(id, user_id)
      route = Route.new(:GET, '/guilds/%{guild_id}/bans/%{user_id}',
                        guild_id: id, user_id: user_id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#create_guild_ban' do
    it 'makes a request with json parameters' do
      client.create_guild_ban(id, user_id, reason: reason)
      route = Route.new(:PUT, '/guilds/%{guild_id}/bans/%{user_id}',
                        guild_id: id, user_id: user_id)
      expect(client).to have_received(:request).with(route, json: { reason: reason })
    end
  end

  describe '#remove_guild_ban' do
    it 'makes a request with no parameters' do
      client.remove_guild_ban(id, user_id, reason: reason)
      route = Route.new(:DELETE, '/guilds/%{guild_id}/bans/%{user_id}',
                        guild_id: id, user_id: user_id)
      expect(client).to have_received(:request).with(route, reason: reason)
    end
  end

  describe '#get_guild_roles' do
    it 'makes a request with no parameters' do
      client.get_guild_roles(id)
      route = Route.new(:GET, '/guilds/%{guild_id}/roles', guild_id: id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#create_guild_role' do
    it 'makes a request with json parameters' do
      client.create_guild_role(id, name: 'role', reason: reason)
      route = Route.new(:POST, '/guilds/%{guild_id}/roles', guild_id: id)
      expect(client).to have_received(:request).with(route, json: { name: 'role' }, reason: reason)
    end
  end

  describe '#modify_guild_role_positoins' do
    it 'makes a request with json parameters' do
      client.modify_guild_role_positions(id, [], reason: reason)
      route = Route.new(:PATCH, '/guilds/%{guild_id}/roles', guild_id: id)
      expect(client).to have_received(:request).with(route, json: [], reason: reason)
    end
  end

  describe '#modify_guild_role' do
    it 'makes a request with json parameters' do
      client.modify_guild_role(id, role_id, name: 'role', reason: reason)
      route = Route.new(:PATCH, '/guilds/%{guild_id}/roles/%{role_id}',
                        guild_id: id, role_id: role_id)
      expect(client).to have_received(:request).with(route, json: { name: 'role' }, reason: reason)
    end
  end

  describe '#delete_guild_role' do
    it 'makes a request with no parameters' do
      client.delete_guild_role(id, role_id, reason: reason)
      route = Route.new(:DELETE, '/guilds/%{guild_id}/roles/%{role_id}', guild_id: id, role_id: role_id)
      expect(client).to have_received(:request).with(route, reason: reason)
    end
  end

  describe '#get_guild_prune_count' do
    it 'makes a request with query parameters' do
      client.get_guild_prune_count(id, days: 7)
      route = Route.new(:GET, '/guilds/%{guild_id}/prune', guild_id: id)
      expect(client).to have_received(:request).with(route, query: { days: 7 })
    end
  end

  describe '#begin_guild_prune' do
    it 'makes a request with json parameters' do
      client.begin_guild_prune(id, days: 7, reason: reason)
      route = Route.new(:POST, '/guilds/%{guild_id}/prune', guild_id: id)
      expect(client).to have_received(:request).with(route, json: { days: 7 }, reason: reason)
    end
  end

  describe '#get_guild_voice_regions' do
    it 'makes a request with no parameters' do
      client.get_guild_voice_regions(id)
      route = Route.new(:GET, '/guilds/%{guild_id}/regions', guild_id: id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#get_guild_invites' do
    it 'makes a request with no parameters' do
      client.get_guild_invites(id)
      route = Route.new(:GET, '/guilds/%{guild_id}/invites', guild_id: id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#get_guild_integrations' do
    it 'makes a request with no parameters' do
      client.get_guild_integrations(id)
      route = Route.new(:GET, '/guilds/%{guild_id}/integrations', guild_id: id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#create_guild_integration' do
    it 'makes a request with json parameters' do
      client.create_guild_integration(id, type: 'foo', id: 'bar')
      route = Route.new(:POST, '/guilds/%{guild_id}/integrations', guild_id: id)
      expect(client).to have_received(:request).with(route, json: { type: 'foo', id: 'bar' })
    end
  end

  describe '#modify_guild_integration' do
    it 'makes a request with json parameters' do
      client.modify_guild_integration(id, integration_id, expire_behavior: 1, reason: reason)
      route = Route.new(:PATCH, '/guilds/%{guild_id}/integrations/%{integration_id}',
                        guild_id: id, integration_id: integration_id)
      expect(client).to have_received(:request).with(route, json: { expire_behavior: 1 }, reason: reason)
    end
  end

  describe '#delete_guild_integration' do
    it 'makes a request with no parameters' do
      client.delete_guild_integration(id, integration_id, reason: reason)
      route = Route.new(:DELETE, '/guilds/%{guild_id}/integrations/%{integration_id}',
                        guild_id: id, integration_id: integration_id)
      expect(client).to have_received(:request).with(route, reason: reason)
    end
  end

  describe '#sync_guild_integration' do
    it 'makes a request with no parameters' do
      client.sync_guild_integration(id, integration_id, reason: reason)
      route = Route.new(:POST, '/guilds/%{guild_id}/integrations/%{integration_id}/sync',
                        guild_id: id, integration_id: integration_id)
      expect(client).to have_received(:request).with(route, reason: reason)
    end
  end

  describe '#get_guild_widget' do
    it 'makes a request with no parameters' do
      client.get_guild_widget(id)
      route = Route.new(:GET, '/guilds/%{guild_id}/widget', guild_id: id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#modify_guild_widget' do
    it 'makes a request with json parameters' do
      client.modify_guild_widget(id, enabled: false, reason: reason)
      route = Route.new(:PATCH, '/guilds/%{guild_id}/widget', guild_id: id)
      expect(client).to have_received(:request).with(route, json: { enabled: false }, reason: reason)
    end
  end

  describe '#get_guild_vanity_url' do
    it 'makes a request with no parameters' do
      client.get_guild_vanity_url(id)
      route = Route.new(:GET, '/guilds/%{guild_id}/vanity-url', guild_id: id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#get_guild_widget_image' do
    it 'makes a request with query parameters' do
      client.get_guild_widget_image(id, style: 'foo')
      route = Route.new(:GET, '/guilds/%{guild_id}/widget.png', guild_id: id)
      expect(client).to have_received(:request).with(route, query: { style: 'foo' }, raw: true)
    end
  end
end
