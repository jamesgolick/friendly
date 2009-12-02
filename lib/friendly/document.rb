module Friendly
  module Document
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end

    module ClassMethods
      def attribute(name, type)
        attributes << Attribute.new(name, type)
        attr_accessor name
      end

      def attributes
        @attributes ||= []
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
  end
end
