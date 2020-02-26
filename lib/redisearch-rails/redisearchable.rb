module RediSearch
  module RediSearchable
    autoload :ClassMethods, 'redisearch-rails/redisearchable/class_methods'
    autoload :InstanceMethods, 'redisearch-rails/redisearchable/instance_methods'

    extend ActiveSupport::Concern

    included do
      extend RediSearch::RediSearchable::ClassMethods
    end

  end
end
