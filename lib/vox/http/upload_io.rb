# frozen_string_literal: true

require 'vox/http/util'

module Vox
  module HTTP
    # Wrapper to faraday's UploadIO that allows for an optional MIME type
    class UploadIO < Faraday::UploadIO
      include Util

      # @param file [File, IO, String] A File, IO, or file path for the upload.
      # @param mime_type [String] The MIME type for the file, if `nil` it will be
      #   inferred from the file path, defaulting to 'application/octet-stream'
      #   if no matching MIME type matches.
      # @param name [String] File name, this can be omitted if the provided file
      #   responds to `path`.
      def initialize(file, mime_type = nil, name = nil)
        mime_type ||= mime_for_file(file.respond_to?(:path) ? file.path : file)
        super(file, mime_type, name)
      end
    end
  end
end
