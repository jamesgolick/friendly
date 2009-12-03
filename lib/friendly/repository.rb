require 'active_support/core_ext/hash'

module Friendly
  class Repository
    RESERVED_ATTRS = [:id, :created_at, :updated_at].freeze

    attr_reader :db, :serializer, :persister

    def initialize(db, serializer, persister)
      @db         = db
      @serializer = serializer
      @persister  = persister
    end

    def save(doc)
      persister.save(doc)
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

      def populate_indexes(doc)
        doc.indexes.each do |index|
          dataset(index).insert(index_attrs_for(doc, index).merge(:id => doc.id))
        end
      end

      def update_indexes(doc)
        doc.indexes.each do |index|
          dataset(index).where(:id => doc.id).update(index_attrs_for(doc, index))
        end
      end

      def index_attrs_for(doc, index)
        Hash[*index.fields.map { |f| [f, doc.send(f)] }.flatten]
      end
  end
end
