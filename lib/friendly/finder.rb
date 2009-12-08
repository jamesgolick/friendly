module Friendly
  class Finder
    attr_reader :datastore, :translator

    def initialize(datastore, translator)
      @datastore  = datastore
      @translator = translator
    end

    def find!(klass, *ids)
      perform_find(klass, ids, true)
    end

    def find(klass, *ids)
      perform_find(klass, ids, false)
    end

    def find_one(klass, id, bang = false)
      record = datastore.first(klass, :id => id)
      assert_record_found(record, klass, id) if bang
      record && translator.to_object(klass, record)
    end

    def find_many(klass, ids, bang = false)
      records = datastore.all(klass, :id => ids)
      assert_all_records_found(klass, records, ids) if bang
      records.map { |r| translator.to_object(klass, r) }
    end

    protected
      def perform_find(klass, ids, bang)
        ids.length == 1 ? find_one(klass, ids.first, bang) : 
            find_many(klass, ids, bang)
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
