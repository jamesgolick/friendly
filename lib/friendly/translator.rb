module Friendly
  class Translator
    RESERVED_ATTRS = [:id, :created_at, :updated_at].freeze

    attr_reader :serializer, :time

    def initialize(serializer = JSON, time = Time)
      @serializer = serializer
      @time       = time
    end

    def to_object(klass, record)
      record.delete(:added_id)
      attributes = serializer.parse(record.delete(:attributes))
      attributes.merge!(record).merge!(:new_record => false)
      klass.new_without_change_tracking attributes
    end

    def to_record(document)
      { :id         => document.id,
        :created_at => document.created_at,
        :updated_at => time.new,
        :attributes => serialize(document) }
    end

    protected
      def serialize(document)
        attrs = document.to_hash.reject { |k,v| RESERVED_ATTRS.include?(k) }
        serializer.generate(attrs)
      end
  end
end

