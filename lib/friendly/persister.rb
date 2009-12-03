module Friendly
  class Persister
    RESERVED_ATTRS = [:id, :created_at, :updated_at].freeze

    attr_reader :datastore, :serializer, :time

    def initialize(datastore, serializer = JSON, time = Time)
      @datastore  = datastore
      @serializer = serializer
      @time       = time
    end

    def save(document)
      document.new_record? ? create(document) : update(document)
    end

    def create(document)
      table_attrs = table_attrs(document)
      id = datastore.insert(document, serialize(document).merge(table_attrs))
      document.attributes = table_attrs.merge(:id => id)
    end

    def update(document)
      table_attrs = table_attrs(document)
      datastore.update(document, document.id, serialize(document).merge(table_attrs))
      document.attributes = table_attrs
    end

    protected
      def table_attrs(document)
        created_at = time.new
        {:created_at => document.created_at || created_at,
         :updated_at => created_at}
      end

      def serialize(document)
        attrs = document.to_hash.reject { |k,v| RESERVED_ATTRS.include?(k) }
        {:attributes => serializer.generate(attrs)}
      end
  end
end
