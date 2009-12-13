require 'friendly/storage_factory'
require 'friendly/table_creator'

module Friendly
  class StorageProxy
    attr_reader :klass, :storage_factory, :tables, :table_creator, :caches

    def initialize(klass, storage_factory = StorageFactory.new,
                    table_creator=TableCreator.new)
      super()
      @klass           = klass
      @storage_factory = storage_factory
      @table_creator   = table_creator
      @tables          = [storage_factory.document_table(klass)]
      @caches          = []
    end

    def first(conditions)
      index_for(conditions).first(conditions)
    end

    def all(conditions)
      index_for(conditions).all(conditions)
    end

    def add(*args)
      tables << storage_factory.index(klass, *args)
    end

    def cache(fields)
      caches << storage_factory.cache(klass, fields)
    end

    def create(document)
      each_store { |s| s.create(document) }
    end

    def update(document)
      each_store { |s| s.update(document) }
    end

    def destroy(document)
      stores.reverse.each { |i| i.destroy(document) }
    end

    def create_tables!
      tables.each { |t| table_creator.create(t) }
    end

    def index_for(conditions)
      index = tables.detect { |i| i.satisfies?(conditions) }
      if index.nil?
        raise MissingIndex, "No index found to satisfy: #{conditions.inspect}."
      end
      index
    end

    protected
      def each_store
        stores.each { |s| yield(s) }
      end

      def stores
        tables + caches
      end
  end
end
