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
        assign_default_values
        self.attributes = opts
      end

      def attributes=(attrs)
        assert_no_duplicate_keys(attrs)
        attrs.each { |name, value| send("#{name}=", value) }
      end

      def to_hash
        Hash[*self.class.attributes.keys.map { |n| [n, send(n)] }.flatten]
      end

      def assign_default_values
        self.class.attributes.values.each { |a| a.assign_default_value(self) }
      end

      def assign(name, value)
        send(:"#{name}=", value)
      end

      protected
        def assert_no_duplicate_keys(hash)
          if hash.keys.map { |k| k.to_s }.uniq.length < hash.keys.length
            raise ArgumentError, "Duplicate keys: #{hash.inspect}"
          end
        end
    end
  end
end
