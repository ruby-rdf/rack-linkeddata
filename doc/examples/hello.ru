#!/usr/bin/env rackup
$:.unshift(::File.expand_path(::File.join(::File.dirname(__FILE__), '..', '..', 'lib')))
require 'rack/linkeddata'

rdf = RDF::Graph.new do
  self << [RDF::Node.new, RDF::DC.title, "Hello, world!"]
end

use Rack::LinkedData::ContentNegotiation
run lambda { |env| [200, {}, rdf] }
