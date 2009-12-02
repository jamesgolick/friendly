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
      db_record = dataset(klass).first(:id => id)
      attrs     = serializer.parse(db_record[:attributes])
      klass.new attrs.merge(:id => db_record[:id])
    end

    protected
      def dataset(object)
        db.from(object.table_name)
      end
  end
end
