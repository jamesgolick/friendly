require 'set'

module Friendly
  class IndexSet < Set
    attr_reader :klass, :index_klass

    def initialize(klass, index_klass = Index)
      super()
      @klass       = klass
      @index_klass = index_klass
    end

    def first(conditions)
      index_for(conditions).first(conditions)
    end

    def all(conditions)
      index_for(conditions).all(conditions)
    end

    def add(*args)
      self << index_klass.new(klass, *args)
    end

    def create(document)
      each { |i| i.create(document) }
    end

    def update(document)
      each { |i| i.update(document) }
    end

    def index_for(conditions)
      index = detect { |i| i.satisfies?(conditions) }
      if index.nil?
        raise MissingIndex, "No index found to satisfy: #{conditions.inspect}."
      end
      index
    end
  end
end
