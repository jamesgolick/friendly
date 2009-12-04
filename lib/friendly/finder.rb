module Friendly
  class Finder
    attr_reader :datastore, :translator

    def initialize(datastore, translator)
      @datastore  = datastore
      @translator = translator
    end

    def find(klass, *ids)
      ids.length == 1 ? find_one(klass, ids.first) : find_many(klass, ids)
    end

    def find_one(klass, id)
      record = datastore.first(klass, :id => id)
      assert_record_found(record, klass, id)
      translator.to_object(klass, record)
    end

    def find_many(klass, ids)
      records = datastore.all(klass, :id => ids)
      assert_all_records_found(klass, records, ids)
      records.map { |r| translator.to_object(klass, r) }
    end

    protected
      def deserialize(json)
        serializer.parse(json).symbolize_keys
      end

      def assert_record_found(record, klass, id)
        if record.nil?
          raise RecordNotFound, "Couldn't find record #{klass.name}: #{id}."
        end
      end

      def assert_all_records_found(klass, records, ids)
        missing = ids - records.map { |r| r[:id] }
        unless missing.empty?
          missing = missing.join(",")
          raise RecordNotFound, "Couldn't find records #{klass.name}: #{missing}."
        end
      end
  end
end
