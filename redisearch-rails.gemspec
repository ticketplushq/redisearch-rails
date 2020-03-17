# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "redisearch-rails/version"

Gem::Specification.new do |spec|
  spec.name          = "redisearch-rails"
  spec.version       = RediSearch::VERSION
  spec.authors       = ["Patricio Beckmann"]
  spec.email         = ["pato.beckmann@gmail.com"]

  spec.summary       = %q{RediSearch on Rails}
  spec.description   = %q{'Index and search Rails models on redisearch'}
  spec.homepage      = "https://github.com/Ticketplus/redisearch-rails"
  spec.required_ruby_version = '>= 2.3'
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activerecord', '~> 4.2'
  spec.add_dependency 'activesupport', '~> 4.2'
  spec.add_dependency 'activejob', '~> 4.2'
  spec.add_dependency 'redi_searcher', '~> 0.1', '>= 0.1.3'

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
end
