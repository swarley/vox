# frozen_string_literal: true

require 'rspec'
require 'vox/http/route'

RSpec.describe Vox::HTTP::Route do
  describe '#initialize' do
    it 'normalizes HTTP verbs' do
      correct_route = described_class.new(:get, '')

      routes = ['get', 'GET', :GET].collect { |verb| described_class.new(verb, '') }
      expect(routes).to all(eq correct_route)
    end
  end

  describe '#major_param' do
    context 'when there are no major parameters' do
      it 'returns nil' do
        route = described_class.new(:GET, '')
        expect(route.major_param).to be_nil
      end
    end

    context 'when there are major parameters' do
      it 'returns the correct parameter' do
        gid = instance_double('Integer')
        route = described_class.new(:GET, '', nonsense: nil, guild_id: gid)
        expect(route.major_param).to eq gid
      end
    end
  end

  describe '#format' do
    context 'when there is no major parameter' do
      it 'returns the path' do
        route = described_class.new(:GET, '/test')
        expect(route.format).to eq '/test'
      end
    end

    context 'when there is a major parameter' do
      it 'returns a formatted path' do
        channel_id = 1234
        route = described_class.new(:GET, '/channels/%{channel_id}', channel_id: channel_id)

        expect(route.format).to eq "/channels/#{channel_id}"
      end
    end
  end

  describe '#rl_key' do
    context 'when there are no parameters' do
      it 'returns a ratelimit key in the format of `verb:key:`' do
        route = described_class.new(:GET, '/test')
        expect(route.rl_key).to eq 'get:/test:'
      end
    end

    context 'when there are no major parameters' do
      it 'returns a ratelimit key in the format of `verb:key:`' do
        param = 1234
        route = described_class.new(:GET, '/test/%{param}', param: param)
        expect(route.rl_key).to eq 'get:/test/%{param}:'
      end
    end

    context 'when there is a major parameter' do
      it 'returns a ratelimit key in the format of `verb:key:major`' do
        major = 1234
        route = described_class.new(:GET, '/channels/%{channel_id}', channel_id: major)
        expect(route.rl_key).to eq "get:/channels/%{channel_id}:#{major}"
      end
    end

    context 'when there are multiple parameters including a major parameter' do
      it 'returns a ratelimit key in the format of `verb:key:major`' do
        major = 1234
        unused_param = instance_double('NilClass')

        route = described_class.new(:GET, '/channels/%{channel_id}', channel_id: major, unused: unused_param)
        expect(route.rl_key).to eq "get:/channels/%{channel_id}:#{major}"
      end
    end
  end
end
