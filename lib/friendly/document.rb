require 'active_support/inflector'

module Friendly
  module Document
    def self.included(klass)
      klass.class_eval do
        extend ClassMethods
        attribute :id,         Fixnum
        attribute :created_at, Time
      end
    end

    module ClassMethods
      def attribute(name, type)
        attributes << Attribute.new(name, type)
        attr_accessor name
      end

      def attributes
        @attributes ||= []
      end

      def find(id)
        Friendly.config.repository.find(self, id)
      end

      def table_name
        name.pluralize.underscore
      end
    end

    def initialize(opts = {})
      self.attributes = opts
    end

    def attributes=(attrs)
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
  end
end
