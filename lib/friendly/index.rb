module Friendly
  class Index
    attr_reader :klass, :fields

    def initialize(klass, fields)
      @klass  = klass
      @fields = fields
    end

    def table_name
      ["index", klass.table_name, "on", fields.join("_and_")].join("_")
    end

    def satisfies?(conditions)
      (conditions.keys.map { |k| k.to_sym } - fields).empty?
    end
  end
end
