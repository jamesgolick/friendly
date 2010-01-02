require 'friendly/document/mixin'

module Friendly
  module Document
    module Attributes
      extend Mixin

      module ClassMethods
        def attribute(name, type = nil, options = {})
          attributes[name] = Attribute.new(self, name, type, options)
        end

        def attributes
          @attributes ||= {}
        end
      end

      def initialize(opts = {})
        self.attributes = opts
      end

      def attributes=(attrs)
        assert_no_duplicate_keys(attrs)
        attrs.each { |name, value| send("#{name}=", value) }
      end

      def to_hash
        Hash[*self.class.attributes.keys.map { |n| [n, send(n)] }.flatten]
      end
    end
  end
end
