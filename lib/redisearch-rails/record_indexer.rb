module RediSearch
  class RecordIndexer

    attr_reader :record, :index

    def initialize(record)
      @record = record
      @index = record.class.redisearch_index
    end

    def reindex(mode: nil, **options)
      unless [:inline, true, nil, :async].include?(mode)
        raise ArgumentError, "#{mode} its not a valid value for mode"
      end

      mode ||= RediSearch.callbacks_value || record.class.redisearch_index_options[:callbacks] || true

      case mode
      when :async
        RediSearch::ReindexRecordJob.perform_later(record.class.name, record.id.to_s)
      else
        reindex_record
      end
    end

    private

    def reindex_record
      if record.destroyed? || !record.persisted? || !record.should_index?
        document = index.generate_document(record.redisearch_document_id, {})
        document.del(dd: true)
      else
        record.redisearch_add
      end
    end
  end
end
