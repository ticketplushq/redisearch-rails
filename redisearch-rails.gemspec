# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redisearch-rails/version"

Gem::Specification.new do |s|
  s.name        = "redisearch-rails"
  s.version     = RediSearch::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Patricio Beckmann"]
  s.email       = ["pato.beckmann@gmail.com"]
  s.homepage    = "https://github.com/Ticketplus/redisearch-rails"
  s.summary     = %q{RediSearch on Rails}
  s.description = %q{'Index and search Rails models on redisearch'}
  s.required_ruby_version = '>= 2.3'
  s.license     = 'MIT'

  s.add_dependency 'activerecord', '>= 4.2'
  s.add_dependency 'activesupport', '>= 4.2'

  s.add_dependency "redi_searcher", '>= 0.1.1'

  s.files         = `git ls-files`.split("\n").reject { |f| f.match(%r{^(spec/)}) }

  s.require_paths = ["lib"]
end
