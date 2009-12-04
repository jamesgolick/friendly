module Friendly
  class Finder
    attr_reader :datastore, :translator

    def initialize(datastore, translator)
      @datastore  = datastore
      @translator = translator
    end

    def find(klass, id)
      translator.to_object(klass, datastore.first(klass, :id => id))
    end

    protected
      def deserialize(json)
        serializer.parse(json).symbolize_keys
      end
  end
end
