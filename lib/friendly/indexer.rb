module Friendly
  class Indexer
    attr_reader :datastore

    def initialize(datastore)
      @datastore = datastore
    end

    def create(document)
      document.indexes.each do |i|
        datastore.insert(i, index_record(i, document))
      end
    end

    def update(document)
      document.indexes.each do |i|
        datastore.update(i, document.id, index_record(i, document))
      end
    end

    protected
      def index_record(index, document)
        index_fields = index.fields.map { |f| [f, document.send(f)] }.flatten
        Hash[*index_fields].merge(:id => document.id)
      end
  end
end
