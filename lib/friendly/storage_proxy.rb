module Friendly
  class StorageProxy
    attr_reader :klass, :index_klass, :doctable_klass, :tables

    def initialize(klass, index_klass = Index, doctable_klass = DocumentTable)
      super()
      @klass          = klass
      @index_klass    = index_klass
      @doctable_klass = doctable_klass
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

    def index_for(conditions)
      index = tables.detect { |i| i.satisfies?(conditions) }
      if index.nil?
        raise MissingIndex, "No index found to satisfy: #{conditions.inspect}."
      end
      index
    end
  end
end
