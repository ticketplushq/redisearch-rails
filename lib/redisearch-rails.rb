require 'redisearch-rails/configuration'

require "active_support/lazy_load_hooks"

require 'redi_searcher'

module RediSearch
  autoload :RediSearchable, 'redisearch-rails/redisearchable'
  autoload :BatchesIndexer, 'redisearch-rails/batches_indexer'
  autoload :RecordIndexer, 'redisearch-rails/record_indexer'

  #jobs
  autoload :ReindexRecordJob, 'redisearch-rails/reindex_record_job'
  autoload :ReindexBatchesJob, 'redisearch-rails/reindex_batches_job'

  DEFAULT_BATCH_SIZE = 1_000

  class << self
    attr_accessor :models
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

    def enable_callbacks
      self.callbacks_value = nil
    end

    def disable_callbacks
      self.callbacks_value = false
    end

    def callbacks?(default: true)
      if self.callbacks_value.nil?
        default
      else
        self.callbacks_value != false
      end
    end

    def callbacks_value
      Thread.current[:redisearch_callbacks_enabled]
    end

    def callbacks_value=(value)
      Thread.current[:redisearch_callbacks_enabled] = value
    end

    def callbacks(value)
      if block_given?
        previous_value = self.callbacks_value
        begin
          self.callbacks_value = value
          result = yield
          result
        ensure
          self.callbacks_value = previous_value
        end
      else
        self.callbacks_value = value
      end
    end

    private

    def method_missing(m, *args, &block)
      return configuration.send(m) if configuration.respond_to?(m)
      super
    end
  end

  @models = []

end

ActiveSupport.on_load(:active_record) do
  include RediSearch::RediSearchable
end
