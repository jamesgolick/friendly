require 'active_support/inflector'

module Friendly
  module Document
    def self.included(klass)
      klass.class_eval do
        extend ClassMethods
        attribute :id,         Fixnum
        attribute :created_at, Time
        attribute :updated_at, Time
      end
    end

    module ClassMethods
      def attribute(name, type)
        attributes << Attribute.new(name, type)
        attr_accessor name
      end

      def indexes(*args);end

      def attributes
        @attributes ||= []
      end

      def find(*ids)
        Friendly.config.repository.find(self, *ids)
      end

      def table_name
        name.pluralize.underscore
      end
    end

    def initialize(opts = {})
      self.attributes = opts
    end

    def attributes=(attrs)
      assert_no_duplicate_keys(attrs)
      attrs.each { |name, value| send("#{name}=", value) }
    end

    def save
      Friendly.config.repository.save(self)
    end

    def to_hash
      Hash[*self.class.attributes.map { |a| [a.name, send(a.name)] }.flatten]
    end

    def table_name
      self.class.table_name
    end

    def new_record?
      id.nil?
    end

    def ==(comparison_object)
      comparison_object.equal?(self) ||
        (comparison_object.is_a?(self.class) &&
          !comparison_object.new_record? && 
            comparison_object.id == id)
    end

    protected
      def assert_no_duplicate_keys(hash)
        if hash.keys.map { |k| k.to_s }.uniq.length < hash.keys.length
          raise ArgumentError, "Duplicate keys: #{hash.inspect}"
        end
      end
  end
end
