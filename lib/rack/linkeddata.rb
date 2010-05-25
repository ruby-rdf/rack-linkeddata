require 'rack'
require 'linkeddata'

module Rack
  module LinkedData
    autoload :ContentNegotiation, 'rack/linkeddata/conneg'
    autoload :VERSION,            'rack/linkeddata/version'
  end
end
