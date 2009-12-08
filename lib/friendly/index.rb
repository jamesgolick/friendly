module Friendly
  class Index
    attr_reader :klass, :fields, :datastore

    def initialize(klass, fields, datastore = Friendly.datastore)
      @klass     = klass
      @fields    = fields
      @datastore = datastore
    end

    def table_name
      ["index", klass.table_name, "on", fields.join("_and_")].join("_")
    end

    def satisfies?(conditions)
      condition_fields = conditions.keys.map { |k| k.to_sym }
      exact_match?(condition_fields) || valid_partial_match?(condition_fields)
    end

    def first(conditions)
      row = datastore.first(self, conditions)
      row && row[:id]
    end

    def all(conditions)
      datastore.all(self, conditions).map { |row| row[:id] }
    end

    def create(document)
      datastore.insert(self, record(document))
    end

    def update(document)
      datastore.update(self, document.id, record(document))
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

      def record(document)
        Hash[*(fields + [:id]).map { |f| [f, document.send(f)] }.flatten]
      end
  end
end
