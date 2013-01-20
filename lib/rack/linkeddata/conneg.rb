module Rack; module LinkedData
  ##
  # Rack middleware for Linked Data content negotiation.
  #
  # Uses HTTP Content Negotiation to find an appropriate RDF
  # format to serialize any result with a body being `RDF::Enumerable`.
  #
  # Override content negotiation by setting the :format option to
  # {#initialize}.
  #
  # Add a :default option to set a content type to use when nothing else
  # is found.
  #
  # @example
  #     use Rack::LinkedData::ContentNegotation, :format => :ttl
  #     use Rack::LinkedData::ContentNegotiation, :format => RDF::NTriples::Format
  #     use Rack::LinkedData::ContentNegotiation, :default => 'application/rdf+xml'
  #
  # @see http://www4.wiwiss.fu-berlin.de/bizer/pub/LinkedDataTutorial/
  class ContentNegotiation
    DEFAULT_CONTENT_TYPE = "text/plain" # N-Triples
    VARY = {'Vary' => 'Accept'}.freeze

    # @return [#call]
    attr_reader :app

    # @return [Hash{Symbol => Object}]
    attr_reader :options

    ##
    # @param  [#call]                  app
    # @param  [Hash{Symbol => Object}] options
    #   Other options passed to writer.
    # @option options [String] :default (DEFAULT_CONTENT_TYPE) Specific content type
    # @option options [RDF::Format, #to_sym] :format Specific RDF writer format to use
    def initialize(app, options = {})
      @app, @options = app, options
      @options[:default] = (@options[:default] || DEFAULT_CONTENT_TYPE).to_s
    end

    ##
    # Handles a Rack protocol request.
    #
    # @param  [Hash{String => String}] env
    # @return [Array(Integer, Hash, #each)]
    # @see    http://rack.rubyforge.org/doc/SPEC.html
    def call(env)
      response = app.call(env)
      body = response[2].respond_to?(:body) ? response[2].body : response[2]
      case body
        when RDF::Enumerable
          response[2] = body  # Put it back in the response, it might have been a proxy
          serialize(env, *response)
        else response
      end
    end

    ##
    # Serializes an `RDF::Enumerable` response into a Rack protocol
    # response using HTTP content negotiation rules or a specified Content-Type.
    #
    # @param  [Hash{String => String}] env
    # @param  [Integer]                status
    # @param  [Hash{String => Object}] headers
    # @param  [RDF::Enumerable]        body
    # @return [Array(Integer, Hash, #each)]
    def serialize(env, status, headers, body)
      begin
        writer, content_type = find_writer(env, headers)
        if writer
          # FIXME: don't overwrite existing Vary headers
          headers = headers.merge(VARY).merge('Content-Type' => content_type)
          [status, headers, [writer.dump(body, nil, @options)]]
        else
          not_acceptable
        end
      rescue RDF::WriterError => e
        not_acceptable
      end
    end

    ##
    # Returns an `RDF::Writer` class for the given `env`.
    #
    # If options contain a `:format` key, it identifies the specific format to use;
    # otherwise, if the environment has an HTTP_ACCEPT header, use it to find a writer;
    # otherwise, use the default content type
    #
    # @param  [Hash{String => String}] env
    # @param  [Hash{String => Object}] headers
    # @return [Array(Class, String)]
    # @see    http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html
    def find_writer(env, headers)
      if @options[:format]
        format = @options[:format]
        writer = RDF::Writer.for(format.to_sym) unless format.is_a?(RDF::Format)
        return [writer, writer.format.content_type.first] if writer
      elsif env.has_key?('HTTP_ACCEPT')
        content_types = parse_accept_header(env['HTTP_ACCEPT'])
        content_types.each do |content_type|
          writer, content_type = find_writer_for_content_type(content_type)
          return [writer, content_type] if writer
        end
        return nil
      else
        # HTTP/1.1 §14.1: "If no Accept header field is present, then it is
        # assumed that the client accepts all media types"
        find_writer_for_content_type(options[:default])
      end
    end

    ##
    # Returns an `RDF::Writer` class for the given `content_type`.
    #
    # @param  [String, #to_s] content_type
    # @return [Array(Class, String)]
    def find_writer_for_content_type(content_type)
      writer = case content_type.to_s
        when '*/*'
          RDF::Writer.for(:content_type => (content_type = options[:default]))
        when /^([^\/]+)\/\*$/
          nil # TODO: match subtype wildcards
        else
          RDF::Writer.for(:content_type => content_type)
      end
      writer ? [writer, content_type] : nil
    end

    protected

    ##
    # Parses an HTTP `Accept` header, returning an array of MIME content
    # types ordered by the precedence rules defined in HTTP/1.1 §14.1.
    #
    # @param  [String, #to_s] header
    # @return [Array<String>]
    # @see    http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    def parse_accept_header(header)
      content_types = header.to_s.split(',').map do |content_type_and_weight|
        content_type_and_weight.strip!
        case content_type_and_weight
          when /^([^;]+);\s*q=(\d+\.\d+)$/
            [[1.0, $2.to_f].min, $1, content_type_and_weight]
          when /(\S+)/
            [1.0, $1, content_type_and_weight]
          else nil
        end
      end
      content_types.compact! # remove nils
      content_types = content_types.sort_by { |elem| [elem[0], elem[2].size] }
      content_types.reverse.map { |elem| elem[1] }
    end

    ##
    # Outputs an HTTP `406 Not Acceptable` response.
    #
    # @param  [String, #to_s] message
    # @return [Array(Integer, Hash, #each)]
    def not_acceptable(message = nil)
      http_error(406, message, VARY)
    end

    ##
    # Outputs an HTTP `4xx` or `5xx` response.
    #
    # @param  [Integer, #to_i]         code
    # @param  [String, #to_s]          message
    # @param  [Hash{String => String}] headers
    # @return [Array(Integer, Hash, #each)]
    def http_error(code, message = nil, headers = {})
      message = http_status(code) + (message.nil? ? "\n" : " (#{message})\n")
      [code, {'Content-Type' => 'text/plain; charset=utf-8'}.merge(headers), [message]]
    end

    ##
    # Returns the standard HTTP status message for the given status `code`.
    #
    # @param  [Integer, #to_i] code
    # @return [String]
    def http_status(code)
      [code, Rack::Utils::HTTP_STATUS_CODES[code]].join(' ')
    end
  end # class ContentNegotiation
end; end # module Rack::LinkedData
