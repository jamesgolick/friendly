require 'active_support/inflector'

module Friendly
  module Document
    class << self
      attr_writer :documents

      def included(klass)
        documents << klass
        klass.class_eval do
          extend ClassMethods
          attribute :id,         UUID
          attribute :created_at, Time
          attribute :updated_at, Time
        end
      end

      def documents
        @documents ||= []
      end

      def create_tables!
        documents.each { |d| d.create_tables! }
      end
    end

    module ClassMethods
      attr_writer :storage_proxy, :query_klass, 
                  :table_name,    :collection_klass,
                  :scope_proxy

      def create_tables!
        storage_proxy.create_tables!
      end

      def attribute(name, type = nil, options = {})
        attributes[name] = Attribute.new(self, name, type, options)
      end

      def storage_proxy
        @storage_proxy ||= StorageProxy.new(self)
      end

      def query_klass
        @query_klass ||= Query
      end

      def collection_klass
        @collection_klass ||= WillPaginate::Collection
      end

      def indexes(*args)
        storage_proxy.add(args)
      end

      def caches_by(*fields)
        options = fields.last.is_a?(Hash) ? fields.pop : {}
        storage_proxy.cache(fields, options)
      end

      def attributes
        @attributes ||= {}
      end

      def first(query)
        storage_proxy.first(query(query))
      end

      def all(query)
        storage_proxy.all(query(query))
      end

      def find(id)
        doc = first(:id => id)
        raise RecordNotFound, "Couldn't find #{name}/#{id}" if doc.nil?
        doc
      end

      def count(conditions)
        storage_proxy.count(query(conditions))
      end

      def paginate(conditions)
        query      = query(conditions)
        count      = count(query)
        collection = collection_klass.new(query.page, query.per_page, count)
        collection.replace(all(query))
      end

      def create(attributes = {})
        doc = new(attributes)
        doc.save
        doc
      end

      def table_name
        @table_name ||= name.pluralize.underscore
      end

      def scope_proxy
        @scope_proxy ||= ScopeProxy.new(self)
      end

      # Add a named scope to this Document.
      #
      # e.g.
      #     
      #     class Post
      #       indexes     :created_at
      #       named_scope :recent, :order! => :created_at.desc
      #     end
      #
      # Then, you can access the recent posts with:
      #
      #     Post.recent.all
      # ...or...
      #     Post.recent.first
      #
      # Both #all and #first also take additional parameters:
      #
      #     Post.recent.all(:author_id => @author.id)
      #
      # Scopes are presently not chainable, though that is coming soon.
      #
      # @param [Symbol] name the name of the scope.
      # @param [Hash] parameters the query that this named scope will perform.
      #
      def named_scope(name, parameters)
        scope_proxy.add_named(name, parameters)
      end

      protected
        def query(conditions)
          conditions.is_a?(Query) ? conditions : query_klass.new(conditions)
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

    def update_attributes(attributes)
      self.attributes = attributes
      save
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
