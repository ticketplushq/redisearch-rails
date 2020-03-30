module RediSearch
  module RediSearchable
    module ClassMethods

      def redisearch(*args, schema:, **options)
        options = RediSearch.model_options.merge(options)

        raise "Only call redisearch once per model" if respond_to?(:redisearch_index)

        prefix = options[:prefix] || RediSearch.index_prefix
        prefix = prefix.call if prefix.respond_to?(:call)

        suffix = options[:suffix] || RediSearch.index_suffix
        suffix = suffix.call if suffix.respond_to?(:call)

        callbacks = options.key?(:callbacks) ? options[:callbacks] : :inline
        unless [:inline, true, false, :async].include?(callbacks)
          raise ArgumentError, "#{callbacks} its not permited value for callbacks"
        end

        class << self
          attr_reader :redisearch_index, :redisearch_index_serializer, :redisearch_index_options
        end

        index_name = [prefix, model_name.plural, suffix].compact.join("_")
        @redisearch_index_serializer = options[:index_serializer]
        @redisearch_index = RediSearch.client.generate_index(index_name, schema)

        RediSearch.models << self

        @redisearch_index_options = options

        scope :redisearch_import, -> { all }

        # always add callbacks, even when callbacks is false
        # so Model.callbacks block can be used
        if respond_to?(:after_commit)
          after_commit :reindex, if: -> { RediSearch.callbacks?(default: callbacks) }
        elsif respond_to?(:after_save)
          after_save :reindex, if: -> { RediSearch.callbacks?(default: callbacks) }
          after_destroy :reindex, if: -> { RediSearch.callbacks?(default: callbacks) }
        end

        include InstanceMethods
        extend RediSearchClassMethods
      end
    end

    module RediSearchClassMethods

      def redisearch(query, load: true, **options)
        result = redisearch_index.search(query, options.deep_merge(nocontent: true))
        result.shift # remove the first element (count)
        result.map! { |elem| elem.sub("#{redisearch_index.name}_", '')}
        return result unless load
        self.find(result)
      end

      def redisearch_count(query = '*')
        redisearch_index.search(query, limit: [0, 0]).shift
      end

      # Reindex all
      def reindex(recreate: false, mode: :inline, **options)
        index = redisearch_index

        index.drop if recreate
        index.create unless index.exists?

        RediSearch::BatchesIndexer.new(self).reindex(mode: mode)
      end

    end
  end
end
