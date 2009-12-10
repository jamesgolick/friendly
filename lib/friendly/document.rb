require 'active_support/inflector'

module Friendly
  module Document
    def self.included(klass)
      klass.class_eval do
        extend ClassMethods
        attribute :id,         UUID
        attribute :created_at, Time
        attribute :updated_at, Time
      end
    end

    module ClassMethods
      attr_writer :storage_proxy, :query_klass, :table_name

      def attribute(name, type = nil)
        attributes[name] = Attribute.new(self, name, type)
      end

      def storage_proxy
        @storage_proxy ||= StorageProxy.new(self)
      end

      def query_klass
        @query_klass ||= Query
      end

      def indexes(*args)
        storage_proxy.add(args)
      end

      def attributes
        @attributes ||= {}
      end

      def first(query)
        storage_proxy.first(query_klass.new(query))
      end

      def all(query)
        storage_proxy.all(query_klass.new(query))
      end

      def find(id)
        doc = first(:id => id)
        raise RecordNotFound, "Couldn't find #{name}/#{id}" if doc.nil?
        doc
      end

      def table_name
        @table_name ||= name.pluralize.underscore
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
      new_record? ? storage_proxy.create(self) : storage_proxy.update(self)
    end

    def destroy
      storage_proxy.destroy(self)
    end

    def to_hash
      Hash[*self.class.attributes.keys.map { |n| [n, send(n)] }.flatten]
    end

    def table_name
      self.class.table_name
    end

    def new_record?
      new_record
    end

    def new_record
      @new_record = true if @new_record.nil?
      @new_record
    end

    def new_record=(value)
      @new_record = value
    end

    def storage_proxy
      self.class.storage_proxy
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
