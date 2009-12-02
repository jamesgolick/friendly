module Friendly
  class Repository
    attr_reader :db, :serializer, :time

    def initialize(db, serializer, time)
      @db         = db
      @serializer = serializer
      @time       = time
    end

    def save(doc)
      created_at          = time.new
      serialized_document = serializer.generate(doc.to_hash)
      id = dataset(doc).insert(:attributes => serialized_document,
                               :created_at => created_at)
      doc.id         = id
      doc.created_at = created_at
    end

    def find(klass, id)
      db_record = dataset(klass).first(:id => id)
      attrs     = serializer.parse(db_record[:attributes])
      klass.new attrs.merge(:id         => db_record[:id],
                            :created_at => db_record[:created_at])
    end

    protected
      def dataset(object)
        db.from(object.table_name)
      end
  end
end
