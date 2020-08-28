# frozen_string_literal: true

require 'rspec'

require 'vex/http/routes/user'

RSpec.describe Vex::HTTP::Routes::User do
  let(:client) { Class.new { include Vex::HTTP::Routes::User }.new }
  let(:id) { 'id' }
  let(:reason) { instance_double('String') }

  before do
    stub_const('Route', Vex::HTTP::Route)
    allow(client).to receive(:request).with(any_args)
  end

  describe '#get_current_user' do
    it 'sends a request with no parameters' do
      client.get_current_user
      route = Route.new(:GET, '/users/@me')
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#get_user' do
    it 'sends a request with no parameters' do
      client.get_user(id)
      route = Route.new(:GET, '/users/%{user_id}', user_id: id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#modify_current_user' do
    it 'sends a request with json parameters' do
      client.modify_current_user(username: 'name')
      route = Route.new(:PATCH, '/users/@me')
      expect(client).to have_received(:request).with(route, json: { username: 'name' })
    end

    context 'when the avatar parameter is passed' do
      let(:avatar_data) { 'avatar_data' }
      let(:avatar_b64) { Base64.encode64(avatar_data) }
      let(:avatar) { UploadIO.new(StringIO.new(avatar_data), 'image/jpeg') }

      it 'sends base64 encoded data' do
        client.modify_current_user(avatar: avatar)
        route = Route.new(:PATCH, '/users/@me')
        expect(client).to have_received(:request).with(
          route, json: { avatar: "data:#{avatar.content_type};base64,#{avatar_b64}" }
        )
      end
    end
  end

  describe '#get_current_user_guilds' do
    it 'sends a request with query parameters' do
      client.get_current_user_guilds(limit: 5)
      route = Route.new(:GET, '/users/@me/guilds')
      expect(client).to have_received(:request).with(route, query: { limit: 5 })
    end
  end

  describe '#leave_guild' do
    it 'sends a request with no parameters' do
      client.leave_guild(id)
      route = Route.new(:DELETE, '/users/@me/guilds/%{guild_id}', guild_id: id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#get_user_dms' do
    it 'sends a request with no parameters' do
      client.get_user_dms
      route = Route.new(:GET, '/users/@me/channels')
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#create_dm' do
    it 'sends a request with json parameters' do
      client.create_dm(id)
      route = Route.new(:POST, '/users/@me/channels')
      expect(client).to have_received(:request).with(route, json: { recipient_id: id })
    end
  end

  describe '#create_group_dm' do
    it 'sends a request with json parameters' do
      client.create_group_dm([id])
      route = Route.new(:POST, '/users/@me/channels')
      expect(client).to have_received(:request).with(route, json: { access_tokens: [id] })
    end
  end

  describe '#get_user_connections' do
    it 'sends a request with no parameters' do
      client.get_user_connections
      route = Route.new(:GET, '/users/@me/connections')
      expect(client).to have_received(:request).with(route)
    end
  end
end
