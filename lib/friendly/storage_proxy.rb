require 'friendly/table_creator'

module Friendly
  class StorageProxy
    attr_reader :klass, :index_klass, :doctable_klass, :tables, :table_creator

    def initialize(klass, index_klass=Index, doctable_klass=DocumentTable,
                    table_creator=TableCreator.new)
      super()
      @klass          = klass
      @index_klass    = index_klass
      @doctable_klass = doctable_klass
      @table_creator  = table_creator
      @tables         = [doctable_klass.new(klass)]
    end

    def first(conditions)
      index_for(conditions).first(conditions)
    end

    def all(conditions)
      index_for(conditions).all(conditions)
    end

    def add(*args)
      tables << index_klass.new(klass, *args)
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
