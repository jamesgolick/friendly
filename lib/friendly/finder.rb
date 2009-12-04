module Friendly
  class Finder
    attr_reader :datastore, :translator

    def initialize(datastore, translator)
      @datastore  = datastore
      @translator = translator
    end

    def find(klass, id)
      record = datastore.first(klass, :id => id)
      assert_record_found(record, klass, id)
      translator.to_object(klass, record)
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
  end
end
