# frozen_string_literal: true

require 'rspec'
require 'vex/http/client'

def make_path(endpoint)
  "/api/v#{Vex::HTTP::Client::API_VERSION}/#{endpoint.delete_prefix('/')}"
end

def stub_route_ok(endpoint, stubs)
  stubs.get(make_path(endpoint)) do |env|
    yield(env)
    [200, {}, '{}']
  end
end

def stub_error_status(endpoint, status, stubs)
  stubs.get(make_path(endpoint)) do |_|
    [status, {}, '{}']
  end
end

RSpec.describe Vex::HTTP::Client do
  let(:client) do
    described_class.new('Bot dummy.token') do |f|
      f.adapter(:test, stubs)
    end
  end
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }

  before do
    stub_const('Route', Vex::HTTP::Route)
    stub_const('Error', Vex::HTTP::Error)
  end

  describe '#inspect' do
    it { expect(client.inspect).to match(/^\#<Vex::HTTP::Client:0x\h+>$/) }
  end

  describe '#request' do
    let(:okay_response) { [200, {}, '{}'] }

    context 'when making a request with no parameters' do
      it 'does not pass query string or json data' do
        stub_route_ok('no_params', stubs) do |env|
          expect([env.params, env.body]).to all(be_empty.or(be_nil))
        end
        client.request(Route.new(:GET, '/no_params'))
      end
    end

    context 'when making a request with a json body' do
      let(:obj) { { hello: 'world' } }

      it 'sets the content-type header' do
        stub_route_ok('json', stubs) do |env|
          expect(env.request_headers['Content-Type']).to eq 'application/json'
        end
        client.request(Route.new(:GET, '/json'), json: obj)
      end

      it 'sends serialized json objects' do
        stub_route_ok('json', stubs) do |env|
          expect(env.body).to eq MultiJson.dump(obj)
        end
        client.request(Route.new(:GET, '/json'), json: obj)
      end
    end

    context 'when sending a non `data` body' do
      it 'does not serialize the data' do
        data = instance_double('String')
        stub_route_ok('data', stubs) do |env|
          expect(env.body).to eq data
        end
        client.request(Route.new(:GET, '/data'), data: data)
      end
    end

    context 'when exceeding a rate limit' do
      let(:rl_response) do
        [
          429,
          {
            'X-RateLimit-Limit': '1',
            'X-RateLimit-Bucket': 'ratelimit',
            'X-RateLimit-Remaining': '0',
            'X-RateLimit-Reset-After': '0'
          },
          '{}'
        ]
      end

      # rubocop:disable RSpec/ExampleLength
      it 'retries the request' do
        access_count = 0
        stubs.get(make_path('ratelimit')) do
          if access_count.zero?
            access_count += 1
            rl_response
          else
            expect(access_count).to eq 1
            [200, {}, '{}']
          end
        end
        client.request(Route.new(:GET, '/ratelimit'))
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when receiving a 400' do
      it 'raises an Error::BadRequest' do
        stub_error_status('bad_req', 400, stubs)
        route = Route.new(:GET, '/bad_req')
        expect { client.request(route) }.to raise_error(Error::BadRequest)
      end
    end

    context 'when receiving a 401' do
      it 'raises an Error::Unauthorized' do
        stub_error_status('unauth', 401, stubs)
        route = Route.new(:GET, '/unauth')
        expect { client.request(route) }.to raise_error(Error::Unauthorized)
      end
    end

    context 'when receiving a 403' do
      it 'raises an Error::Forbidden' do
        stub_error_status('forbidden', 403, stubs)
        route = Route.new(:GET, '/forbidden')
        expect { client.request(route) }.to raise_error(Error::Forbidden)
      end
    end

    context 'when receiving a 404' do
      it 'raises an Error::NotFound' do
        stub_error_status('not_found', 404, stubs)
        route = Route.new(:GET, '/not_found')
        expect { client.request(route) }.to raise_error(Error::NotFound)
      end
    end

    context 'when receiving a 405' do
      it 'raises an Error::MethodNotAllowed' do
        stub_error_status('bad_method', 405, stubs)
        route = Route.new(:GET, '/bad_method')
        expect { client.request(route) }.to raise_error(Error::MethodNotAllowed)
      end
    end

    context 'when receiving a 500..600' do
      it 'raises an Error::ServerError' do
        stub_error_status('server_error', 502, stubs)
        route = Route.new(:GET, '/server_error')
        expect { client.request(route) }.to raise_error(Error::ServerError)
      end
    end
  end
end
