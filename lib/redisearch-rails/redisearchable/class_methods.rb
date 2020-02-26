module RediSearch
  module RediSearchable
    module ClassMethods

      attr_reader :redisearch_index

      def redisearch(*args, schema:, **options)
        prefix = options[:prefix]

        index_name = [prefix, model_name.plural].compact.join("_")
        @redisearch_index = RediSearch.client.generate_index(index_name, schema)

        scope :redisearch_import, -> { all }

        include InstanceMethods
        extend RediSearchClassMethods
      end

    end

    module RediSearchClassMethods

      def redisearch(query, **options)
        result = redisearch_index.search(query, options.deep_merge(nocontent: true))
        result.shift # remove the first element (count)
        self.find(result)
      end

      # Reindex all
      def reindex(recreate: false, only: [], **options)
        index = redisearch_index

        index.drop if recreate
        index.create unless index.exists?

        redisearch_import.find_in_batches do |elements|
          redisearch_index.client.multi do
            elements.each do |element|
              element.redisearch_document.add(options.deep_merge(replace: true, partial: true))
            end
          end
        end
      end
    end
  end
end
