module RediSearch
  module RediSearchable
    module InstanceMethods

      def redisearch_document
        @redisearch_document ||= generate_redisearch_document
      end

      private

      def generate_redisearch_document
        index = self.class.redisearch_index
        fields = index.schema.fields.map(&:name)
        fields_values = Hash[fields.flatten.map! { |field| [field, public_send(field)] }]
        index.generate_document(redisearch_document_id, fields_values)
      end

      def redisearch_document_id
        "0#{id}"
      end

    end
  end
end
