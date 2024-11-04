#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'rack-linkeddata'
  gem.homepage           = 'https://github.com/ruby-rdf/rack-linkeddata'
  gem.license            = 'Unlicense'
  gem.summary            = 'Linked Data content negotiation for Rack applications.'
  gem.description        = 'Rack middleware for Linked Data content negotiation.'
  gem.metadata           = {
    "documentation_uri" => "https://ruby-rdf.github.io/rack-linkeddata",
    "bug_tracker_uri"   => "https://github.com/ruby-rdf/rack-linkeddata/issues",
    "homepage_uri"      => "https://github.com/ruby-rdf/rack-linkeddata",
    "mailing_list_uri"  => "https://lists.w3.org/Archives/Public/public-rdf-ruby/",
    "source_code_uri"   => "https://github.com/ruby-rdf/rack-linkeddata",
  }

  gem.authors            = ['Arto Bendiken', 'Gregg Kellogg']
  gem.email              = 'public-rdf-ruby@w3.org'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS CREDITS README.md UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.require_paths      = %w(lib)

  gem.required_ruby_version      = '>= 3.0'
  gem.requirements               = []
  gem.add_runtime_dependency     'linkeddata', '~> 3.3'
  gem.add_runtime_dependency     'rack-rdf',   '~> 3.3'
  gem.add_runtime_dependency     'rack',       '~> 3.1'

  gem.add_development_dependency 'yard' ,      '~> 0.9'
  gem.add_development_dependency 'rspec',      '~> 3.12'
  gem.add_development_dependency 'rack-test',  '~> 2.1'
  gem.post_install_message       = nil
end
