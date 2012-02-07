#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'rack-linkeddata'
  gem.homepage           = 'http://github.com/datagraph'
  gem.license            = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary            = 'Linked Data content negotiation for Rack applications.'
  gem.description        = 'Rack middleware for Linked Data content negotiation.'
  gem.rubyforge_project  = 'datagraph'

  gem.author             = 'Datagraph'
  gem.email              = 'datagraph@googlegroups.com'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS CREDITS README UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.bindir             = %q(bin)
  gem.executables        = %w()
  gem.default_executable = gem.executables.first
  gem.require_paths      = %w(lib)
  gem.extensions         = %w()
  gem.test_files         = %w()
  gem.has_rdoc           = false

  gem.required_ruby_version      = '>= 1.8.1'
  gem.requirements               = []
  gem.add_development_dependency 'yard' ,      '>= 0.6.0'
  gem.add_development_dependency 'rspec',      '>= 2.1.0'
  gem.add_development_dependency 'rack-test',  '>= 0.5.6'
  gem.add_runtime_dependency     'linkeddata', '~> 0.3.2'
  gem.add_runtime_dependency     'rack',       '>= 1.0'
  gem.post_install_message       = nil
end
