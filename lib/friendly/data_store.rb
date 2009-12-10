module Friendly
  class DataStore
    attr_reader :database

    def initialize(database)
      @database = database
    end

    def insert(persistable, attributes)
      batch? ? batch_insert(persistable, attributes) :
        immediate_insert(persistable, attributes)
    end

    def all(persistable, query)
      filtered = dataset(persistable).where(query.conditions)
      if query.limit || query.offset
        filtered = filtered.limit(query.limit, query.offset)
      end
      filtered = filtered.order(query.order) if query.order
      filtered.map
    end

    def first(persistable, query)
      dataset(persistable).first(query.conditions)
    end

    def update(persistable, id, attributes)
      dataset(persistable).where(:id => id).update(attributes)
    end

    def delete(persistable, id)
      dataset(persistable).where(:id => id).delete
    end

    protected
      def dataset(persistable)
        database.from(persistable.table_name)
      end

      def immediate_insert(persistable, attributes)
        dataset(persistable).insert(attributes)
      end

      def batch_insert(persistable, attributes)
        Thread.current[:friendly_batch][persistable.table_name] ||= []
        Thread.current[:friendly_batch][persistable.table_name] << attributes
      end

      def batch?
        Thread.current[:friendly_batch]
      end
  end
end
