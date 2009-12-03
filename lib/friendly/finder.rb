module Friendly
  class Finder

    attr_reader :datastore, :serializer

    def initialize(datastore, serializer)
      @datastore  = datastore
      @serializer = serializer
    end

    def find(klass, id)
      record = datastore.first(klass, :id => id)

      klass.new deserialize(record[:attributes]).merge(:id => record[:id],
                                                       :created_at => record[:created_at],
                                                       :updated_at => record[:updated_at])
    end

    protected

      def deserialize(json)
        serializer.parse(json).symbolize_keys
      end

  end
end
