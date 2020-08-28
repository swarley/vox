# frozen_string_literal: true

require 'rspec'
require 'vox/http/middleware'

RSpec.describe Vox::HTTP::Middleware::RateLimiter do
  let(:shared_bucket) { 'deadbeef' }
  let(:conn) do
    Faraday.new do |f|
      f.adapter :test do |stub|
        stub.get('/locked') do |env|
          sleep 5 if env.request.context[:rl_key] == 'lock'
          [200, {}, '{}']
        end

        stub.get('/shared') do |_|
          [
            200,
            {
              'X-RateLimit-Limit': '5',
              'X-RateLimit-Bucket': shared_bucket,
              'X-RateLimit-Remaining': '5',
              'X-RateLimit-Reset-After': '5.0'
            },
            '{}'
          ]
        end

        stub.get('/empty') do |_|
          [
            200,
            {
              'X-RateLimit-Limit': '1',
              'X-RateLimit-Bucket': shared_bucket,
              'X-RateLimit-Remaining': '0',
              'X-RateLimit-Reset-After': '10000.0'
            },
            '{}'
          ]
        end

        stub.get('/global') do |_|
          [
            429,
            {
              'Retry-After': '50000',
              'X-RateLimit-Global': 'true'
            },
            '{}'
          ]
        end

        stub.get('/fast') do |_|
          [
            200,
            {
              'X-RateLimit-Limit': '1',
              'X-RateLimit-Bucket': 'fast',
              'X-RateLimit-Remaining': '0',
              'X-RateLimit-Reset-After': '0.1'
            },
            '{}'
          ]
        end

        stub.get('/non_global') do |_|
          [
            429,
            {
              'X-RateLimit-Limit': '1',
              'X-RateLimit-Bucket': 'non_global',
              'X-RateLimit-Remaining': '0',
              'X-RateLimit-Reset-After': '0',
              'Retry-After': '10000'
            },
            '{}'
          ]
        end
      end
      f.use :vox_ratelimiter
    end
  end

  describe '#call' do
    let(:locked_req) do
      proc do
        conn.get('/locked') do |req|
          req.options.context = { rl_key: 'lock' }
        end
      end
    end

    let(:unlocked_req) do
      proc do
        conn.get('/locked') do |req|
          req.options.context = { rl_key: 'unlocked' }
        end
      end
    end

    let(:empty_bucket) do
      proc do
        conn.get('/empty') do |req|
          req.options.context = { rl_key: 'empty' }
        end
      end
    end

    let(:shared_bucket) do
      proc do
        conn.get('/shared') do |req|
          req.options.context = { rl_key: 'shared' }
        end
      end
    end

    let(:global_rl) do
      proc do
        conn.get('/global') do |req|
          req.options.context = { rl_key: 'global' }
        end
      end
    end

    let(:non_global) do
      proc do
        conn.get('/non_global') do |req|
          req.options.context = { rl_key: 'non_global' }
        end
      end
    end

    let(:fast) do
      proc do
        conn.get('/fast') do |req|
          req.options.context = { rl_key: 'fast' }
        end
      end
    end

    context 'when the same rl_key is being accessed from different requests' do
      it 'will not allow them to run in parallel' do
        Thread.new { locked_req.call }
        expect { Timeout.timeout(0.1) { locked_req.call } }.to raise_error(Timeout::Error)
      end
    end

    context 'when the same route with a different rl_key is being access from different requests' do
      it 'will allow them to run in parallel' do
        Thread.new { locked_req.call }
        expect { Timeout.timeout(0.1) { unlocked_req.call } }.not_to raise_error
      end
    end

    context 'when the rl_key bucket is empty' do
      it 'waits for the reset' do
        empty_bucket.call
        expect { Timeout.timeout(0.1) { empty_bucket.call } }.to raise_error(Timeout::Error)
      end
    end

    context 'when a non global 429 is encountered' do
      it 'waits for the retry duration' do
        non_global.call
        sleep 0.1

        expect { Timeout.timeout(0.1) { non_global.call } }.to raise_error(Timeout::Error)
      end
    end

    context 'when the bucket ID is empty' do
      it 'waits for the reset' do
        shared_bucket.call
        empty_bucket.call
        expect { Timeout.timeout(0.1) { shared_bucket.call } }.to raise_error(Timeout::Error)
      end
    end

    context 'when the global ratelimit is hit' do
      it 'blocks all requests until it resets' do
        global_rl.call
        sleep 0.1

        [locked_req, unlocked_req].each do |req|
          expect { Timeout.timeout(0.1) { req.call } }.to raise_error(Timeout::Error)
        end
      end
    end

    context 'when the reset time is finished' do
      it 'unlocks the mutex' do
        fast.call
        sleep 0.1

        expect { Timeout.timeout(0.1) { fast.call } }.not_to raise_error
      end
    end
  end
end
