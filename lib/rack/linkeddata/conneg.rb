module Rack; module LinkedData
  ##
  # Rack middleware for Linked Data content negotiation.
  #
  # @see http://www4.wiwiss.fu-berlin.de/bizer/pub/LinkedDataTutorial/
  class ContentNegotiation
    DEFAULT_CONTENT_TYPE = "text/plain"

    # @return [#call]
    attr_reader :app

    # @return [Hash{Symbol => Object}]
    attr_reader :options

    ##
    # @param  [#call]                   app
    # @param  [Hash{Symbol => Object}]  options
    # @option options [String] :default (DEFAULT_CONTENT_TYPE)
    def initialize(app, options = {})
      @app, @options = app, options.to_hash.dup
    end

    ##
    # @param  [Hash{String => String}]  env
    # @return [Array(Integer, Hash, #each)]
    # @see    http://rack.rubyforge.org/doc/SPEC.html
    def call(env)
      case (response = app.call(env)).last
        when RDF::Enumerable
          serialize(*response)
        else response
      end
    end

    ##
    # @param  [Integer]                 status
    # @param  [Hash{String => Object}]  headers
    # @param  [RDF::Enumerable]         body
    # @return [Array(Integer, Hash, #each)]
    def serialize(status, headers, body)
      # TODO
      [status, headers, body]
    end
  end # class ContentNegotiation
end; end # module Rack::LinkedData
