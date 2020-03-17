module RediSearch
  class Configuration
    attr_accessor :redis_config, :index_prefix, :index_suffix, :queue_name, :model_options

    def initialize
      @redis_config = {}
      @index_prefix = nil
      @index_suffix = nil
      @queue_name = :redisearch
      @model_options = {}
    end
  end
end
