module RediSearch
  class ReindexRecordJob < ActiveJob::Base
    RECORD_NOT_FOUND_CLASSES = [
      "ActiveRecord::RecordNotFound"
    ]

    queue_as { RediSearch.queue_name }

    def perform(klass, id)
      model = klass.constantize

      record =
        begin
          model.redisearch_import.find(id)
        rescue => e
          # check by name rather than rescue directly so we don't need
          # to determine which classes are defined
          raise e unless RECORD_NOT_FOUND_CLASSES.include?(e.class.name)
          nil
        end

        unless record
          record = model.new
          record.id = id
        end

      RecordIndexer.new(record).reindex(mode: :inline)
    end
  end
end
