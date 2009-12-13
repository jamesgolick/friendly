require 'friendly/table_creator'

module Friendly
  class StorageProxy
    attr_reader :klass, :table_factory, :tables, :table_creator

    def initialize(klass, table_factory = TableFactory.new,
                    table_creator=TableCreator.new)
      super()
      @klass          = klass
      @table_factory  = table_factory
      @table_creator  = table_creator
      @tables         = [table_factory.document_table(klass)]
    end

    def first(conditions)
      index_for(conditions).first(conditions)
    end

    def all(conditions)
      index_for(conditions).all(conditions)
    end

    def add(*args)
      tables << table_factory.index(klass, *args)
    end

    def create(document)
      tables.each { |i| i.create(document) }
    end

    def update(document)
      tables.each { |i| i.update(document) }
    end

    def destroy(document)
      tables.reverse.each { |i| i.destroy(document) }
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
  end
end
