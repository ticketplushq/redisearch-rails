module RediSearch
  class ReindexBatchesJob < ActiveJob::Base
    queue_as { RediSearch.queue_name }

    def perform(klass, start, finish, batch_size)
      klass = klass.constantize

      start = start.to_i
      finish = finish.to_i
      batch_size = batch_size.to_i
      
      batches_relation = nil

      if ActiveRecord::VERSION::STRING >= "5.0"
        batches_relation = klass.redisearch_import.find_in_batches(batch_size: batch_size, start: start, finish: finish)
      else
        batches_relation = klass.redisearch_import.where(klass.arel_table[:id].lteq(finish.to_i)).find_in_batches(batch_size: batch_size, start: start)
      end

      batches_relation.each do |records|
        klass.redisearch_index.client.multi do
          records.each do |record|
            record.reindex(mode: :inline, replace: true)
          end
        end
      end

    end
  end
end
