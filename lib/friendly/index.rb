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
        sorted = condition_fields.sort do |a,b|
          fields.index(a) || 0 <=> fields.index(b) || 0
        end
        fields.zip(sorted).all? { |a,b| a == b || b.nil? }
      end
  end
end
