require 'redisearch-rails/configuration'

require "active_support/lazy_load_hooks"

module RediSearch
  autoload :RediSearchable, 'redisearch-rails/redisearchable'

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def client
      @client ||= RediSearcher::Client.new(configuration.redis_config)
    end

  end
end

ActiveSupport.on_load(:active_record) do  
  include RediSearch::RediSearchable
end
