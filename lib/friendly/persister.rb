module Friendly
  class Persister
    attr_reader :datastore, :serializer, :time

    def initialize(datastore, serializer = JSON, time = Time)
      @datastore  = datastore
      @serializer = serializer
      @time       = time
    end

    def save(document)
      table_attrs = table_attrs(document)
      id = datastore.insert(document, serialize(document).merge(table_attrs))
      document.attributes = table_attrs.merge(:id => id)
    end

    protected
      def table_attrs(document)
        created_at = time.new
        {:created_at => created_at, :updated_at => created_at}
      end

      def serialize(document)
        {:attributes => serializer.generate(document.to_hash)}
      end
  end
end
