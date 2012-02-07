require 'rack'
require 'linkeddata'

module Rack
  module LinkedData
    autoload :ContentNegotiation, 'rack/linkeddata/conneg'
    autoload :VERSION,            'rack/linkeddata/version'

    ##
    # Registers all known RDF formats with Rack's MIME types registry.
    #
    # @param  [Hash{Symbol => Object}] options
    # @option options [Boolean]        :overwrite (false)
    # @return [void]
    def self.register_mime_types!(options = {})
      if defined?(Rack::Mime::MIME_TYPES)
        RDF::Format.file_extensions.each do |file_ext, formats|
          if !Rack::Mime::MIME_TYPES.has_key?(file_ext = ".#{file_ext}") || options[:overwrite]
            Rack::Mime::MIME_TYPES.merge!(file_ext => formats.first.content_type.first)
          end
        end
      end
    end
  end
end

Rack::LinkedData.register_mime_types!
