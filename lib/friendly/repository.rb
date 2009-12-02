require 'active_support/core_ext/hash'

module Friendly
  class Repository
    RESERVED_ATTRS = [:id, :created_at, :updated_at].freeze

    attr_reader :db, :serializer, :time

    def initialize(db, serializer, time)
      @db         = db
      @serializer = serializer
      @time       = time
    end

    def save(doc)
      doc.new_record? ? create(doc) : update(doc)
    end

    def find(klass, *ids)
      ids.length > 1 ? find_many(klass, ids) : find_one(klass, ids.first)
    end

    def find_one(klass, id)
      record = dataset(klass).first(:id => id)
      assert_record_found(record, id, klass)
      deserialize_object(klass, record)
    end

    def find_many(klass, ids)
      records = dataset(klass).where(:id => ids).map
      assert_record_found(records, ids, klass)
      records.map { |r| deserialize_object(klass, r) }
    end

    protected
      def dataset(object)
        db.from(object.table_name)
      end

      def serialize(doc)
        hash = doc.to_hash.reject { |k, v| RESERVED_ATTRS.include?(k) }
        serializer.generate(hash)
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

      def deserialize_object(klass, db_record)
        attrs     = serializer.parse(db_record[:attributes]).symbolize_keys
        klass.new attrs.merge(:id         => db_record[:id],
                              :created_at => db_record[:created_at],
                              :updated_at => db_record[:updated_at])
      end

      def assert_record_found(records, ids, klass)
        records = Array(records)
        ids     = Array(ids)

        if records.length < ids.length
          missing = ids - records.map { |r| r[:id] }
          raise RecordNotFound, "Couldn't find records: #{klass.name}/#{missing}."
        end
      end
  end
end
