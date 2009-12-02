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

    def initialize(*args); end

    def save
      Friendly.config.repository.save(self)
    end
  end
end
