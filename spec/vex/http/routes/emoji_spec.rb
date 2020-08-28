# frozen_string_literal: true

require 'rspec'
require 'vex/http/routes/emoji'
require 'base64'
require 'faraday'
require 'multi_json'

RSpec.describe Vex::HTTP::Routes::Emoji do
  let(:client) { Class.new { include Vex::HTTP::Routes::Emoji }.new }
  let(:guild_id) { 'guild_id' }
  let(:emoji_id) { 'emoji_id' }
  let(:reason) { instance_double('String') }

  before do
    stub_const('Route', Vex::HTTP::Route)
    allow(client).to receive(:request).with(any_args)
  end

  describe '#list_guild_emojis' do
    it 'makes a request with no parameters' do
      client.list_guild_emojis(guild_id)
      route = Route.new(:GET, '/guilds/%{guild_id}/emojis', guild_id: guild_id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#get_guild_emoji' do
    it 'makes a request with no parameters' do
      client.get_guild_emoji(guild_id, emoji_id)
      route = Route.new(:GET, '/guilds/%{guild_id}/emojis/%{emoji_id}',
                        guild_id: guild_id, emoji_id: emoji_id)
      expect(client).to have_received(:request).with(route)
    end
  end

  describe '#create_guild_emoji' do
    let(:image_data) { 'vex' }
    let(:image_format) { "data:image/jpeg;base64,#{Base64.encode64(image_data)}" }
    let(:image_file) do
      Vex::HTTP::UploadIO.new(__FILE__)
    end

    context 'when `image` is a File' do
      it 'makes a request with json parameters and encodes the file data' do
        client.create_guild_emoji(guild_id, image: image_file)
        route = Route.new(:POST, '/guilds/%{guild_id}/emojis', guild_id: guild_id)
        expect(client).to have_received(:request).with(
          route, json: { image: a_string_matching(/^data:.+;base64,.+$/m) }
        )
      end
    end
  end

  describe '#modify_guild_emoji' do
    it 'makes a request with json parameters' do
      client.modify_guild_emoji(guild_id, emoji_id, name: 'emoji', reason: reason)
      route = Route.new(:PATCH, '/guilds/%{guild_id}/emojis/%{emoji_id}',
                        guild_id: guild_id, emoji_id: emoji_id)
      expect(client).to have_received(:request).with(route, json: { name: 'emoji' }, reason: reason)
    end
  end

  describe '#delete_guild_emoji' do
    it 'makes a request with no parameters' do
      client.delete_guild_emoji(guild_id, emoji_id, reason: reason)
      route = Route.new(:DELETE, '/guilds/%{guild_id}/emojis/%{emoji_id}',
                        guild_id: guild_id, emoji_id: emoji_id)
      expect(client).to have_received(:request).with(route, reason: reason)
    end
  end
end
