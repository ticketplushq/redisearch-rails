module ModelReconstruction
  def reset_class class_name
    Object.send(:remove_const, class_name) rescue nil
    klass = Object.const_set(class_name, Class.new(ActiveRecord::Base))

    klass.reset_column_information
    klass.connection_pool.clear_table_cache!(klass.table_name) if klass.connection_pool.respond_to?(:clear_table_cache!)

    if klass.connection.respond_to?(:schema_cache)
      if ActiveRecord::VERSION::STRING >= "5.0"
        klass.connection.schema_cache.clear_data_source_cache!(klass.table_name)
      else
        klass.connection.schema_cache.clear_table_cache!(klass.table_name)
      end
    end

    klass
  end

  def rebuild_model model_name, &block
    rebuilt_class = rebuild_class(model_name, &block)
    rebuilt_class.try(:reindex)
  end

  def rebuild_class name, &block
    reset_class(name).tap do |klass|
      klass.class_eval(&block) if block_given?
    end
  end
end
