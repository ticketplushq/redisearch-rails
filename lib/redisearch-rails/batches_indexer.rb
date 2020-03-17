module RediSearch
  class BatchesIndexer

    attr_reader :klass

    def initialize(klass)
      @klass = klass
      @index = klass.redisearch_index
    end

    def reindex(mode: :inline, **options)
      unless [:inline, true, :async].include?(mode)
        raise ArgumentError, "#{mode} its not a valid value for mode"
      end

      batch_size = klass.redisearch_index_options[:batch_size] || DEFAULT_BATCH_SIZE

      #this make a select count
      size = klass.redisearch_import.find_in_batches(batch_size: batch_size).size
      case mode
      when :async
        for i in 1..size
          start = (i-1)*batch_size
          finish = (i*batch_size)-1
          RediSearch::ReindexBatchesJob.perform_later(klass.name, start.to_s, finish.to_s, batch_size.to_s)
        end
      else
        reindex_in_batches(batch_size, options)
      end
    end

    private

    def reindex_in_batches(batch_size, **options)
      klass.redisearch_import.find_in_batches(batch_size: batch_size) do |records|
        klass.redisearch_index.client.multi do
          records.each do |record|
            record.reindex(mode: :inline, **options.deep_merge(replace: true, partial: true))
          end
        end
      end
    end
  end
end
