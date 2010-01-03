require 'friendly/document/mixin'
require 'set'

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

        def new_without_change_tracking(attributes)
          doc = new(attributes)
          doc.reset_changes
          doc
        end
      end

      def initialize(opts = {})
        assign_default_values
        self.attributes = opts
      end

      def attributes=(attrs)
        assert_no_duplicate_keys(attrs)
        attrs.each { |name, value| assign(name, value) }
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

      # Notify the object that an attribute is about to change.
      #
      # @param [Symbol] attribute The name of the attribute about to change.
      #
      def will_change(attribute)
        changed << attribute
        instance_variable_set(:"@#{attribute}_was", send(attribute))
      end

      # Get the original value of an attribute that has changed.
      #
      # @param [Symbol] attribute The name of the attribute.
      #
      def attribute_was(attribute)
        instance_variable_get(:"@#{attribute}_was")
      end

      # Has this attribute changed?
      #
      # @param [Symbol] attribute The name of the attribute.
      #
      def attribute_changed?(attribute)
        changed.include?(attribute)
      end

      # Have any of the attributes that are being tracked changed since last reset?
      #
      def changed?
        !changed.empty?
      end

      # Which attributes that are being tracked have changed since last reset?
      #
      def changed
        @changed ||= Set.new
      end

      # Reset all the changes to this object.
      #
      def reset_changes
        changed.each { |c| not_changed(c) }.clear
      end

      # Reset the changed-ness of one attribute.
      #
      def not_changed(attribute)
        instance_variable_set(:"@#{attribute}_was", nil)
        changed.delete(attribute)
      end

      # Override #save to reset changes afterwards
      #
      # @override
      #
      def save
        super
        reset_changes
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
