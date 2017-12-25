source "https://rubygems.org"

gemspec

gem "linkeddata",         git: "https://github.com/ruby-rdf/linkeddata",          branch: "develop"
gem "rdf",                git: "https://github.com/ruby-rdf/rdf",                 branch: "develop"
gem "rdf-spec",           git: "https://github.com/ruby-rdf/rdf-spec",            branch: "develop"

gem 'rdf-aggregate-repo', git: "https://github.com/ruby-rdf/rdf-aggregate-repo",  branch: "develop"
gem 'rdf-isomorphic',     git: "https://github.com/ruby-rdf/rdf-isomorphic",      branch: "develop"
gem 'rdf-json',           git: "https://github.com/ruby-rdf/rdf-json",            branch: "develop"
gem 'rdf-microdata',      git: "https://github.com/ruby-rdf/rdf-microdata",       branch: "develop"
gem 'rdf-n3',             git: "https://github.com/ruby-rdf/rdf-n3",              branch: "develop"
gem 'rdf-rdfa',           git: "https://github.com/ruby-rdf/rdf-rdfa",            branch: "develop"
gem 'rdf-reasoner',       git: "https://github.com/ruby-rdf/rdf-reasoner",        branch: "develop"
gem 'rdf-rdfxml',         git: "https://github.com/ruby-rdf/rdf-rdfxml",          branch: "develop"
gem 'rdf-tabular',        git: "https://github.com/ruby-rdf/rdf-tabular",         branch: "develop"
gem 'rdf-trig',           git: "https://github.com/ruby-rdf/rdf-trig",            branch: "develop"
gem 'rdf-trix',           git: "https://github.com/ruby-rdf/rdf-trix",            branch: "develop"
gem 'rdf-turtle',         git: "https://github.com/ruby-rdf/rdf-turtle",          branch: "develop"
gem 'rdf-vocab',          git: "https://github.com/ruby-rdf/rdf-vocab",           branch: "develop"
gem 'rdf-xsd',            git: "https://github.com/ruby-rdf/rdf-xsd",             branch: "develop"
gem 'json-ld',            git: "https://github.com/ruby-rdf/json-ld",             branch: "develop"
gem 'ld-patch',           git: "https://github.com/gkellogg/ld-patch",            branch: "develop"
gem 'sparql',             git: "https://github.com/ruby-rdf/sparql",              branch: "develop"
gem 'sparql-client',      git: "https://github.com/ruby-rdf/sparql-client",       branch: "develop"
gem 'nokogiri'

group :development do
  gem "byebug",           platforms: :mri
  gem "ebnf",             git: "https://github.com/gkellogg/ebnf",                branch: "develop"
  gem 'sxp',              git: "https://github.com/dryruby/sxp.rb",               branch: "develop"
end

platforms :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'rubinius', '~> 2.0'
end

case ENV['RACK_VERSION']
when /^1.6/
  gem 'rack', '~> 1.6'
when /^2.0/
  gem 'rack', '~> 2.0'
end
