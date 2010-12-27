Linked Data Content Negotiation for Rack Applications
=====================================================

This is [Rack][] middleware that provides [Linked Data][] content
negotiation for Rack applications. You can use `Rack::LinkedData` with any
Ruby web framework based on Rack, including with Ruby on Rails 3.0 and with
Sinatra.

* <http://github.com/datagraph/rack-linkeddata>

Features
--------

* Implements [HTTP content negotiation][conneg] for RDF content types.
* Supports all [RDF.rb][]-compatible serialization formats.
* Compatible with any Rack application and any Rack-based framework.

Examples
--------

### Adding Linked Data content negotiation to a Rails 3.x application

    # config/application.rb
    require 'rack/linkeddata'
    
    class Application < Rails::Application
      config.middleware.use Rack::LinkedData::ContentNegotiation
    end

### Adding Linked Data content negotiation to a Sinatra application

    #!/usr/bin/env ruby -rubygems
    require 'sinatra'
    require 'rack/linkeddata'
    
    use Rack::LinkedData::ContentNegotiation
    
    get '/hello' do
      RDF::Graph.new do |graph|
        graph << [RDF::Node.new, RDF::DC.title, "Hello, world!"]
      end
    end

### Adding Linked Data content negotiation to a Rackup application

    #!/usr/bin/env rackup
    require 'rack/linkeddata'
    
    rdf = RDF::Graph.new do |graph|
      graph << [RDF::Node.new, RDF::DC.title, "Hello, world!"]
    end
    
    use Rack::LinkedData::ContentNegotiation
    run lambda { |env| [200, {}, rdf] }

### Defining a default Linked Data content type

    use Rack::LinkedData::ContentNegotiation, :default => "text/turtle"

### Testing Linked Data content negotiation using `rackup` and `curl`

    $ rackup doc/examples/hello.ru
    
    $ curl -iH "Accept: text/plain" http://localhost:9292/hello
    $ curl -iH "Accept: text/turtle" http://localhost:9292/hello
    $ curl -iH "Accept: application/rdf+xml" http://localhost:9292/hello
    $ curl -iH "Accept: application/json" http://localhost:9292/hello
    $ curl -iH "Accept: application/trix" http://localhost:9292/hello
    $ curl -iH "Accept: */*" http://localhost:9292/hello

Description
-----------

`Rack::LinkedData` implements content negotiation for any [Rack][] response
object that implements the `RDF::Enumerable` mixin. You would typically
return an instance of `RDF::Graph` or `RDF::Repository` from your Rack
application, and let the `Rack::LinkedData::ContentNegotiation` middleware
take care of serializing your response into whatever RDF format the HTTP
client requested and understands.

The middleware queries [RDF.rb][] for the MIME content types of known RDF
serialization formats, so it will work with whatever serialization plugins
that are currently available for RDF.rb. (At present, this includes support
for N-Triples, Turtle, RDF/XML, RDF/JSON and TriX.)

Documentation
-------------

<http://datagraph.rubyforge.org/rack-linkeddata/>

* {Rack::LinkedData}
  * {Rack::LinkedData::ContentNegotiation}

Dependencies
------------

* [Rack](http://rubygems.org/gems/rack) (>= 1.0.0)
* [Linked Data](http://rubygems.org/gems/linkeddata) (>= 0.3.0)

Installation
------------

The recommended installation method is via [RubyGems](http://rubygems.org/).
To install the latest official release of the gem, do:

    % [sudo] gem install rack-linkeddata

Download
--------

To get a local working copy of the development repository, do:

    % git clone git://github.com/datagraph/rack-linkeddata.git

Alternatively, download the latest development version as a tarball as
follows:

    % wget http://github.com/datagraph/rack-linkeddata/tarball/master

References
----------

* <http://www.w3.org/DesignIssues/LinkedData.html>
* <http://linkeddata.org/docs/how-to-publish>
* <http://linkeddata.org/conneg-303-redirect-code-samples>
* <http://www.w3.org/TR/cooluris/>
* <http://www.w3.org/TR/swbp-vocab-pub/>
* <http://patterns.dataincubator.org/book/publishing-patterns.html>

Authors
-------

* [Arto Bendiken](http://github.com/bendiken) - <http://ar.to/>

License
-------

This is free and unencumbered public domain software. For more information,
see <http://unlicense.org/> or the accompanying {file:UNLICENSE} file.

[Rack]:           http://rack.rubyforge.org/
[RDF.rb]:         http://rdf.rubyforge.org/
[Linked Data]:    http://linkeddata.org/
[conneg]:         http://en.wikipedia.org/wiki/Content_negotiation
