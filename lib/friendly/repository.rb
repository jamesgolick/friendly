module Friendly
  class Repository
    attr_reader :db, :serializer

    def initialize(db, serializer)
      @db         = db
      @serializer = serializer
    end

    def save(doc)
      serialized_document = serializer.generate(doc.to_hash)
      id = db.from(doc.table_name).insert(:attributes => serialized_document)
      doc.id = id
    end
  end
end
