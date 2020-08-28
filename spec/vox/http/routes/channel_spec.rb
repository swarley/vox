# frozen_string_literal: true

require 'rspec'
require 'vox/http/routes/channel'
require 'faraday'
require 'multi_json'

RSpec.describe Vox::HTTP::Routes::Channel do
  let(:client) { Class.new { include Vox::HTTP::Routes::Channel }.new }
  let(:channel_id) { 'channel_id' }
  let(:message_id) { 'message_id' }
  let(:user_id) { 'user_id' }
  let(:emoji) { 'emoji:emoji_id' }
  let(:encoded_emoji) { URI.encode_www_form_component(emoji) }
  let(:content) { 'content' }
  let(:reason) { instance_double('String') }

  before do
    stub_const('Route', Vox::HTTP::Route)
    allow(client).to receive(:request).with(any_args)
  end

  describe '#get_channel' do
    it 'sends a request with no parameters' do
      client.get_channel(channel_id)

      route = Route.new(:GET, '/channels/%{channel_id}', channel_id: channel_id)
      expect(client).to have_received(:request).with route
    end
  end

  describe '#modify_channel' do
    it 'sends a request with json parameters' do
      client.modify_channel(channel_id, name: 'foo', topic: 'bar', reason: reason)

      route = Route.new(:PATCH, '/channels/%{channel_id}', channel_id: channel_id)
      expect(client).to have_received(:request).with(route, json: { name: 'foo', topic: 'bar' }, reason: reason)
    end
  end

  describe '#delete_channel' do
    it 'sends a request with only a reason parameter' do
      client.delete_channel(channel_id, reason: reason)

      route = Route.new(:DELETE, '/channels/%{channel_id}', channel_id: channel_id)
      expect(client).to have_received(:request).with(route, reason: reason)
    end
  end

  describe '#get_channel_messages' do
    it 'sends a request with query arguments' do
      client.get_channel_messages(channel_id, limit: 1)

      route = Route.new(:GET, '/channels/%{channel_id}/messages', channel_id: channel_id)
      expect(client).to have_received(:request).with(route, query: { limit: 1 })
    end
  end

  describe '#get_channel_message' do
    it 'sends a request without arguments' do
      message_id = '12345'
      client.get_channel_message(channel_id, message_id)

      route = Route.new(:GET, '/channels/%{channel_id}/messages/%{message_id}',
                        channel_id: channel_id, message_id: message_id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#create_message' do
    let(:route) { Route.new(:POST, '/channels/%{channel_id}/messages', channel_id: channel_id) }
    let(:file) do
      f = instance_double('Vox::HTTP::UploadIO')
      allow(f).to receive(:io).and_return(__FILE__)
      allow(f).to receive(:content_type).and_return('image/jpeg')
      f
    end

    context 'when no files are being uploaded' do
      it 'sends a request with json arguments' do
        client.create_message(channel_id, content: content)

        expect(client).to have_received(:request).with(route, json: { content: content })
      end
    end

    context 'when a file is being uploaded' do
      it 'sends a request with multipart arguments' do
        client.create_message(channel_id, file: file)

        expect(client).to have_received(:request).with(
          route, data: hash_including(file: file, payload_json: '{}')
        )
      end

      it 'sends a request with multipart attachments using numeric keys' do
        client.create_message(channel_id, attachments: { 'file' => file })

        expect(client).to have_received(:request).with(
          route, data: hash_including(0 => instance_of(Vox::HTTP::UploadIO), :payload_json => '{}')
        )
      end
    end
  end

  describe '#create_reaction' do
    it 'sends a request with no parameters' do
      client.create_reaction(channel_id, message_id, emoji)

      route = Route.new(:PUT, '/channels/%{channel_id}/messages/%{message_id}/reactions/%{emoji}/@me',
                        channel_id: channel_id, message_id: message_id, emoji: encoded_emoji)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#delete_own_reaction' do
    it 'sends a request with no parameters' do
      client.delete_own_reaction(channel_id, message_id, emoji)

      route = Route.new(:DELETE, '/channels/%{channel_id}/messages/%{message_id}/reactions/%{emoji}/@me',
                        channel_id: channel_id, message_id: message_id, emoji: encoded_emoji)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#delete_user_reaction' do
    it 'sends a request with no parameters' do
      user_id = 'user_id'
      client.delete_user_reaction(channel_id, message_id, emoji, user_id)

      route = Route.new(:DELETE, '/channels/%{channel_id}/messages/%{message_id}/reactions/%{emoji}/%{user_id}',
                        channel_id: channel_id, message_id: message_id, emoji: encoded_emoji, user_id: user_id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#get_reactions' do
    let(:route) do
      Route.new(:GET, '/channels/%{channel_id}/messages/%{message_id}/reactions/%{emoji}',
                channel_id: channel_id, message_id: message_id, emoji: encoded_emoji)
    end

    context 'when no optional arguments are given' do
      it 'sends a request with empty query parameters' do
        client.get_reactions(channel_id, message_id, emoji)
        expect(client).to have_received(:request).with(route, query: {})
      end
    end

    context 'when optional arguments are given' do
      it 'sends a request with query parameters' do
        client.get_reactions(channel_id, message_id, emoji, limit: 1)
        expect(client).to have_received(:request).with(route, query: { limit: 1 })
      end
    end
  end

  describe '#delete_all_reactions' do
    it 'sends a request with no parameters' do
      client.delete_all_reactions(channel_id, message_id)

      route = Route.new(:DELETE, '/channels/%{channel_id}/messages/%{message_id}/reactions',
                        channel_id: channel_id, message_id: message_id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#delete_all_reactions_for_emoji' do
    it 'sends a request with no parameters' do
      client.delete_all_reactions_for_emoji(channel_id, message_id, emoji)

      route = Route.new(:DELETE, '/channels/%{channel_id}/messages/%{message_id}/reactions/%{emoji}',
                        channel_id: channel_id, message_id: message_id, emoji: encoded_emoji)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#edit_message' do
    it 'sends a request with json parameters' do
      client.edit_message(channel_id, message_id, content: content)

      route = Route.new(:PATCH, '/channels/%{channel_id}/messages/%{message_id}',
                        channel_id: channel_id, message_id: message_id)
      expect(client).to have_received(:request).with(route, json: { content: content })
    end
  end

  describe '#delete_message' do
    it 'sends a request with no parameters' do
      client.delete_message(channel_id, message_id, reason: reason)

      route = Route.new(:DELETE, '/channels/%{channel_id}/messages/%{message_id}',
                        channel_id: channel_id, message_id: message_id)
      expect(client).to have_received(:request).with(route, reason: reason)
    end
  end

  describe '#bulk_delete_messages' do
    it 'sends a request with json parameters' do
      messages = %w[12345 67890]
      client.bulk_delete_messages(channel_id, messages, reason: reason)

      route = Route.new(:POST, '/channels/%{channel_id}/messages/bulk-delete', channel_id: channel_id)
      expect(client).to have_received(:request).with(route, json: { messages: messages }, reason: reason)
    end
  end

  describe '#edit_channel_permissions' do
    it 'sends a request with json parameters' do
      args = { allow: 123, deny: 456, type: :member }
      client.edit_channel_permissions(channel_id, user_id, **args, reason: reason)

      route = Route.new(:PUT, '/channels/%{channel_id}/permissions/%{overwrite_id}',
                        channel_id: channel_id, overwrite_id: user_id)
      expect(client).to have_received(:request).with(route, json: args, reason: reason)
    end
  end

  describe '#get_channel_invites' do
    it 'sends a request with no parameters' do
      client.get_channel_invites(channel_id)

      route = Route.new(:GET, '/channels/%{channel_id}/invites', channel_id: channel_id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#create_channel_invite' do
    it 'sends a request with json parameters' do
      client.create_channel_invite(channel_id, max_age: 123, reason: reason)

      route = Route.new(:POST, '/channels/%{channel_id}/invites', channel_id: channel_id)
      expect(client).to have_received(:request).with(route, json: { max_age: 123 }, reason: reason)
    end
  end

  describe '#delete_channel_permission' do
    it 'sends a request with no parameters' do
      client.delete_channel_permission(channel_id, user_id, reason: reason)

      route = Route.new(:DELETE, '/channels/%{channel_id}/permissions/%{overwrite_id}',
                        channel_id: channel_id, overwrite_id: user_id)
      expect(client).to have_received(:request).with(route, reason: reason)
    end
  end

  describe '#trigger_typing_indicator' do
    it 'sends a request with no parameters' do
      client.trigger_typing_indicator(channel_id)

      route = Route.new(:POST, '/channels/%{channel_id}/typing', channel_id: channel_id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#get_pinned_messages' do
    it 'sends a request with no parameters' do
      client.get_pinned_messages(channel_id)

      route = Route.new(:GET, '/channels/%{channel_id}/pins', channel_id: channel_id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#add_pinned_channel_message' do
    it 'sends a request with no parameters' do
      client.add_pinned_channel_message(channel_id, message_id, reason: reason)

      route = Route.new(:POST, '/channels/%{channel_id}/pins/%{message_id}',
                        channel_id: channel_id, message_id: message_id)
      expect(client).to have_received(:request).with(route, reason: reason)
    end
  end

  describe '#delete_pinned_channel_message' do
    it 'sends a request with no parameters' do
      client.delete_pinned_channel_message(channel_id, message_id, reason: reason)

      route = Route.new(:DELETE, '/channels/%{channel_id}/pins/%{message_id}',
                        channel_id: channel_id, message_id: message_id)
      expect(client).to have_received(:request).with(route, reason: reason)
    end
  end

  describe '#group_dm_add_recipient' do
    let(:access_token) { 'access_token' }

    it 'sends a request with json parameters' do
      client.group_dm_add_recipient(channel_id, user_id, access_token: access_token)

      route = Route.new(:PUT, '/channels/%{channel_id}/recipients/%{user_id}',
                        channel_id: channel_id, user_id: user_id)
      expect(client).to have_received(:request).with(route, json: { access_token: access_token })
    end
  end

  describe '#group_dm_remove_recipient' do
    it 'sends a request with no parameters' do
      client.group_dm_remove_recipient(channel_id, user_id)

      route = Route.new(:DELETE, '/channels/%{channel_id}/recipients/%{user_id}',
                        channel_id: channel_id, user_id: user_id)
      expect(client).to have_received(:request).with(route)
    end
  end
end
