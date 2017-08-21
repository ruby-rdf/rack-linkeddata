#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'rack-linkeddata'
  gem.homepage           = 'http://ruby-rdf.github.com/rack-linkeddata'
  gem.license            = 'Unlicense'
  gem.summary            = 'Linked Data content negotiation for Rack applications.'
  gem.description        = 'Rack middleware for Linked Data content negotiation.'

  gem.authors            = ['Arto Bendiken']
  gem.email              = 'public-rdf-ruby@w3.org'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS CREDITS README.md UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.bindir             = %q(bin)
  gem.executables        = %w()
  gem.default_executable = gem.executables.first
  gem.require_paths      = %w(lib)
  gem.extensions         = %w()
  gem.test_files         = %w()
  gem.has_rdoc           = false

  gem.required_ruby_version      = '>= 2.2.2'
  gem.requirements               = []
  gem.add_runtime_dependency     'linkeddata', '~> 2.2'
  gem.add_runtime_dependency     'rack',       '>= 1.6', '< 3.0'

  gem.add_development_dependency 'yard' ,      '~> 0.8'
  gem.add_development_dependency 'rspec',      '~> 3.5'
  gem.add_development_dependency 'rack-test',  '~> 0.6'
  gem.post_install_message       = nil
end
