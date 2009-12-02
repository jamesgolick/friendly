module Friendly
  class Repository
    attr_reader :db, :serializer

    def initialize(db, serializer)
      @db         = db
      @serializer = serializer
    end

    def save(doc)
      serialized_document = serializer.generate(doc.to_hash)
      id = dataset(doc).insert(:attributes => serialized_document)
      doc.id = id
    end

    def find(klass, id)
      serialized_doc = dataset(klass).first(:id => id)
      klass.new serializer.parse(serialized_doc)
    end

    protected
      def dataset(object)
        db.from(object.table_name)
      end
  end
end
