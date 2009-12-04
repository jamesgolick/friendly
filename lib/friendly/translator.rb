module Friendly
  class Translator
    attr_reader :serializer

    def initialize(serializer = JSON)
      @serializer = serializer
    end

    def to_object(klass, record)
      attributes = serializer.parse(record.delete(:attributes))
      klass.new attributes.merge(record)
    end
  end
end

