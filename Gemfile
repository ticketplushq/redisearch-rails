source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in redisearch-rails.gemspec
gemspec

# Hinting at development dependencies
# Prevents bundler from taking a long-time to resolve
group :development, :test do
  gem 'sqlite3', '~> 1.3.8', :platforms => :ruby
  gem 'pry'
  gem 'rspec'
end
