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
      condition_fields = conditions.keys.map { |k| k.to_sym }
      exact_match?(condition_fields) || valid_partial_match?(condition_fields)
    end

    protected
      def exact_match?(condition_fields)
        condition_fields.map { |f| f.to_s }.sort == fields.map { |f| f.to_s }.sort
      end

      def valid_partial_match?(condition_fields)
        sorted = condition_fields.sort { |a,b| field_index(a) <=> field_index(b) }
        sorted.zip(fields).all? { |a,b| a == b }
      end

      def field_index(attr)
        fields.index(attr) || 0
      end
  end
end
