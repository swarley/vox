# frozen_string_literal: true

require 'rspec'
require 'vox/http/util'

RSpec.describe Vox::HTTP::Util do
  let(:util) { Class.new { extend Vox::HTTP::Util } }

  describe '#filter_undef' do
    context 'when no `:undef` members' do
      let(:hash) { { foo: true, bar: true } }

      it 'remains the same' do
        expect(util.filter_undef(hash)).to eq hash
      end
    end

    context 'when `:undef` members' do
      let(:hash) { { foo: true, bar: :undef } }
      let(:filtered) { { foo: true } }

      it 'removes them' do
        expect(util.filter_undef(hash)).to eq filtered
      end
    end
  end

  describe '#mime_for_file' do
    let(:file) do
      file = instance_double('File')
      allow(file).to receive(:is_a?).with(File).and_return(true)
      file
    end

    context 'when there is no matching MIME' do
      let(:path) { 'file.__bad_extension__' }

      it 'returns "application/octet-stream" for files' do
        allow(file).to receive(:path).and_return(path)
        expect(util.mime_for_file(file)).to eq 'application/octet-stream'
      end

      it 'returns "application/octet-stream" for paths' do
        expect(util.mime_for_file(path)).to eq 'application/octet-stream'
      end
    end

    context 'when there is a matching MIME' do
      let(:path) { 'file.png' }

      it 'returns an MIME::Type for files' do
        allow(file).to receive(:path).and_return(path)
        expect(util.mime_for_file(file).to_s).to eq 'image/png'
      end

      it 'returns an MIME::Type for paths' do
        expect(util.mime_for_file(path).to_s).to eq 'image/png'
      end
    end
  end
end
