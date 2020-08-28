# frozen_string_literal: true

require 'rspec'

require 'vex/http/routes/invite'

RSpec.describe Vex::HTTP::Routes::Invite do
  let(:client) { Class.new { include Vex::HTTP::Routes::Invite }.new }
  let(:invite_code) { 'invite_code' }
  let(:reason) { instance_double('String') }

  before do
    stub_const('Route', Vex::HTTP::Route)
    allow(client).to receive(:request).with(any_args)
  end

  describe '#get_invite' do
    it 'makes a request with query parameters' do
      client.get_invite(invite_code)
      route = Route.new(:GET, '/invites/%{invite_code}', invite_code: invite_code)
      expect(client).to have_received(:request).with(route, query: {})
    end
  end

  describe '#delete_invite' do
    it 'makes a request with no parameters' do
      client.delete_invite(invite_code, reason: reason)
      route = Route.new(:DELETE, '/invites/%{invite_code}', invite_code: invite_code)
      expect(client).to have_received(:request).with(route, reason: reason)
    end
  end
end
