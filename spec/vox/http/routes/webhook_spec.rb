# frozen_string_literal: true

require 'rspec'

require 'vox/http/routes/user'

RSpec.describe Vox::HTTP::Routes::Webhook do
  let(:client) { Class.new { include Vox::HTTP::Routes::Webhook }.new }
  let(:id) { 'id' }
  let(:token) { 'token' }
  let(:content) { 'content' }

  before do
    stub_const('Route', Vox::HTTP::Route)
    allow(client).to receive(:request).with(any_args)
  end

  describe '#create_webhook' do
    it 'makes a request with json parameters' do
      client.create_webhook(id, name: 'name')
      route = Route.new(:POST, '/channels/%{channel_id}/webhooks', channel_id: id)
      expect(client).to have_received(:request).with(route, json: { name: 'name' })
    end

    context 'when the avatar parameter is provided' do
      let(:avatar_data) { 'avatar_data' }
      let(:avatar_b64) { Base64.encode64(avatar_data) }
      let(:avatar) { UploadIO.new(StringIO.new(avatar_data), 'image/jpeg') }
      let(:avatar_encoded) { "data:#{avatar.content_type};base64,#{avatar_b64}" }

      it 'sends base64 encoded data' do
        client.create_webhook(id, avatar: avatar)
        route = Route.new(:POST, '/channels/%{channel_id}/webhooks', channel_id: id)
        expect(client).to have_received(:request).with(route, json: { avatar: avatar_encoded })
      end
    end
  end

  describe '#get_channel_webhooks' do
    it 'makes a request with no parameters' do
      client.get_channel_webhooks(id)
      route = Route.new(:GET, '/channels/%{channel_id}/webhooks', channel_id: id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#get_guild_webhooks' do
    it 'makes a request with no parameters' do
      client.get_guild_webhooks(id)
      route = Route.new(:GET, '/guilds/%{guild_id}/webhooks', guild_id: id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#get_webhook' do
    it 'makes a request with no parameters' do
      client.get_webhook(id)
      route = Route.new(:GET, '/webhooks/%{webhook_id}', webhook_id: id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#get_webhook_with_token' do
    it 'makes a request with no parameters' do
      client.get_webhook_with_token(id, token)
      route = Route.new(:GET, '/webhooks/%{webhook_id}/%{webhook_token}',
                        webhook_id: id, webhook_token: token)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#modify_webhook' do
    it 'makes a request with json parameters' do
      client.modify_webhook(id, name: 'foo')
      route = Route.new(:PATCH, '/webhooks/%{webhook_id}', webhook_id: id)
      expect(client).to have_received(:request).with(route, json: { name: 'foo' })
    end

    context 'when the avatar parameter is provided' do
      let(:avatar_data) { 'avatar_data' }
      let(:avatar_b64) { Base64.encode64(avatar_data) }
      let(:avatar) { UploadIO.new(StringIO.new(avatar_data), 'image/jpeg') }
      let(:avatar_encoded) { "data:#{avatar.content_type};base64,#{avatar_b64}" }

      it 'sends base64 encoded data' do
        client.modify_webhook(id, avatar: avatar)
        route = Route.new(:PATCH, '/webhooks/%{webhook_id}', webhook_id: id)
        expect(client).to have_received(:request).with(route, json: { avatar: avatar_encoded })
      end
    end
  end

  describe '#modify_webhook_with_token' do
    it 'makes a request with json parameters' do
      client.modify_webhook_with_token(id, token, name: 'foo')
      route = Route.new(:PATCH, '/webhooks/%{webhook_id}/%{webhook_token}',
                        webhook_id: id, webhook_token: token)
      expect(client).to have_received(:request).with(route, json: { name: 'foo' })
    end

    context 'when the avatar parameter is provided' do
      let(:avatar_data) { 'avatar_data' }
      let(:avatar_b64) { Base64.encode64(avatar_data) }
      let(:avatar) { UploadIO.new(StringIO.new(avatar_data), 'image/jpeg') }
      let(:avatar_encoded) { "data:#{avatar.content_type};base64,#{avatar_b64}" }

      it 'sends base64 encoded data' do
        client.modify_webhook_with_token(id, token, avatar: avatar)
        route = Route.new(:PATCH, '/webhooks/%{webhook_id}/%{webhook_token}', webhook_id: id, webhook_token: token)
        expect(client).to have_received(:request).with(route, json: { avatar: avatar_encoded })
      end
    end
  end

  describe '#delete_webhook' do
    it 'makes a request with no parameters' do
      client.delete_webhook(id)
      route = Route.new(:DELETE, '/webhooks/%{webhook_id}', webhook_id: id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#delete_webhook_with_token' do
    it 'makes a request with no parameters' do
      client.delete_webhook_with_token(id, token)
      route = Route.new(:DELETE, '/webhooks/%{webhook_id}/%{webhook_token}',
                        webhook_id: id, webhook_token: token)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#execute_webhook' do
    let(:route) do
      Route.new(:POST, '/webhooks/%{webhook_id}/%{webhook_token}',
                webhook_id: id, webhook_token: token)
    end
    let(:file) { __FILE__ }

    context 'when no files are being uploaded' do
      it 'sends a request with json arguments' do
        client.execute_webhook(id, token, content: content)

        expect(client).to have_received(:request).with(
          route, json: { content: content }, query: {}
        )
      end
    end

    context 'when a file is being uploaded' do
      let(:attachment_data) { hash_including(0 => instance_of(Vox::HTTP::UploadIO), :payload_json => '{}') }
      let(:file_data) { hash_including(file: instance_of(Vox::HTTP::UploadIO), payload_json: '{}') }
      let(:file_io) { Vox::HTTP::UploadIO.new(file) }

      it 'sends a request with multipart arguments' do
        client.execute_webhook(id, token, wait: true, file: file_io)

        expect(client).to have_received(:request).with(
          route, data: file_data, query: { wait: true }
        )
      end

      it 'sends a request with multipart attachments using numeric keys' do
        client.execute_webhook(id, token, wait: true, attachments: { 'file' => file_io })

        expect(client).to have_received(:request).with(
          route, data: attachment_data, query: { wait: true }
        )
      end
    end
  end

  describe '#execute_slack_compatible_webhook' do
    pending # TODO
  end

  describe '#execute_github_compatible_webhook' do
    pending # TODO
  end
end
