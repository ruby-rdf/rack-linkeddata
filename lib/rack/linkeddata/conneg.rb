module Rack; module LinkedData
  ##
  # Rack middleware for Linked Data content negotiation.
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
    # @option options [String] :default (DEFAULT_CONTENT_TYPE)
    # @option options [#to_sym] :format Specific writer format to use
    def initialize(app, options = {})
      @app, @options = app, options.to_hash.dup
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
      case env['REQUEST_METHOD'].to_sym
        when :GET, :HEAD
          case response[2] # the body
            when RDF::Enumerable
              puts "rack: serialize #{response[2]}"
              serialize(env, *response)
            else response
          end
        else response
      end
    end

    ##
    # Serializes an `RDF::Enumerable` response into a Rack protocol
    # response using HTTP content negotiation rules or a specified Content-Type.
    #
    # @param  [Hash{String => String}] env
    #   If options contain a `:format` key, the value
    #   is a symbol or a subtype of RDF::Format and is used to find the writer directly.
    #
    #   Otherwise, env is inspected for HTTP_
    # @param  [Integer]                status
    # @param  [Hash{String => Object}] headers
    # @param  [RDF::Enumerable]        body
    # @return [Array(Integer, Hash, #each)]
    def serialize(env, status, headers, body)
      begin
        writer, content_type = find_writer(env, headers)
        if writer
          headers = headers.merge(VARY).merge('Content-Type' => content_type) # FIXME: don't overwrite existing Vary headers
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
    # otherwise, if a Content-Type header is defined, use it to find the writer;
    # otherwise, if the environment has an HTTP_ACCEPT header, use it to find a writer;
    # otherwise, use the default content type
    #
    # @param  [Hash{String => String}] env
    #   If the options contains a `:format` key, the value
    #   is a symbol or a subtype of RDF::Format and is used to find the writer directly.
    #
    #   Otherwise, env is inspected for HTTP_
    # @param  [Hash{String => Object}] headers
    # @return [Array(Class, String)]
    # @see    http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html
    def find_writer(env, headers)
      if @options[:format]
        format = RDF::Format.for(@options[:format].to_sym)
        return [format.content_types.first, format.writer] if format && format.writer
      elsif headers.has_key?('Content-Type')
        writer, content_type = find_writer_for_content_type(headers['Content-Type'].split(';').first)
        return [writer, content_type] if writer
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
