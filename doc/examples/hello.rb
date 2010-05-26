#!/usr/bin/env ruby -rubygems
require 'sinatra'
require 'rack/linkeddata'

use Rack::LinkedData::ContentNegotiation

get '/hello' do
  RDF::Graph.new do
    self << [RDF::Node.new, RDF::DC.title, "Hello, world!"]
  end
end
