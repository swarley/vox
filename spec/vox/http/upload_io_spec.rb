# frozen_string_literal: true

require 'vox/http/upload_io'
require 'rspec'

RSpec.describe Vox::HTTP::UploadIO do
  describe '#initialize' do
    it 'determines a content type if one is not provided' do
      io = described_class.new(__FILE__)
      expect(io.content_type).to eq 'application/x-ruby'
    end
  end
end
