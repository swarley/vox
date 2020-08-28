# frozen_string_literal: true

require 'rspec'
require 'vex/http/routes/voice'
require 'faraday'
require 'multi_json'

RSpec.describe Vex::HTTP::Routes::Voice do
  let(:client) { Class.new { include Vex::HTTP::Routes::Voice }.new }

  before do
    stub_const('Route', Vex::HTTP::Route)
    allow(client).to receive(:request).with(any_args)
  end

  describe '#list_voice_regions' do
    it 'makes a request with no parameters' do
      client.list_voice_regions
      route = Route.new(:GET, '/voice/regions')
      expect(client).to have_received(:request).with(route)
    end
  end
end
