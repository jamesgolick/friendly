require 'friendly/table'
require 'active_support/inflector'

module Friendly
  class DocumentTable < Table
    attr_reader :klass

    def initialize(datastore, klass)
      super(datastore)
      @klass = klass
    end

    def table_name
      klass.name.pluralize.underscore
    end

    def satisfies?(conditions)
      conditions.keys == [:id]
    end
  end
end
