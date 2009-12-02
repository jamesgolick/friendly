module Friendly
  class Repository
    attr_reader :db, :serializer, :time

    def initialize(db, serializer, time)
      @db         = db
      @serializer = serializer
      @time       = time
    end

    def save(doc)
      if doc.new_record?
        create(doc)
      else
        update(doc)
      end
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

      def serialize(doc)
        serializer.generate(doc.to_hash)
      end

      def create(doc)
        created_at = time.new
        id = dataset(doc).insert(:attributes => serialize(doc),
                                 :created_at => created_at,
                                 :updated_at => created_at)
        doc.id         = id
        doc.created_at = created_at
        doc.updated_at = created_at
      end

      def update(doc)
        updated_at = time.new
        dataset(doc).where(:id => doc.id).update(:attributes => serialize(doc),
                                                 :updated_at => updated_at)
        doc.updated_at = updated_at
      end
  end
end
