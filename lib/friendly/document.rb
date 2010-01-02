require 'active_support/inflector'
require 'friendly/associations'
require 'friendly/document/attributes'
require 'friendly/document/scoping'
require 'friendly/document/storage'

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
      attr_writer :query_klass,      :table_name,
                  :collection_klass, :association_set

      def query_klass
        @query_klass ||= Query
      end

      def collection_klass
        @collection_klass ||= WillPaginate::Collection
      end

      def find(id)
        doc = first(:id => id)
        raise RecordNotFound, "Couldn't find #{name}/#{id}" if doc.nil?
        doc
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


      def association_set
        @association_set ||= Associations::Set.new(self)
      end

      # Add a has_many association.
      #
      # e.g.
      #
      #     class Post
      #       attribute :user_id, Friendly::UUID
      #       indexes   :user_id
      #     end
      #      
      #     class User
      #       has_many :posts
      #     end
      #     
      #     @user = User.create
      #     @post = @user.posts.create
      #     @user.posts.all == [@post] # => true
      #
      # _Note: Make sure that the target model is indexed on the foreign key. If it isn't, querying the association will raise Friendly::MissingIndex._
      #
      # Friendly defaults the foreign key to class_name_id just like ActiveRecord.
      # It also converts the name of the association to the name of the target class just like ActiveRecord does.
      #
      # The biggest difference in semantics between Friendly's has_many and active_record's is that Friendly's just returns a Friendly::Scope object. If you want all the associated objects, you have to call #all to get them. You can also use any other Friendly::Scope method.
      #
      # @param [Symbol] name The name of the association and plural name of the target class.
      # @option options [String] :class_name The name of the target class of this association if it is different than the name would imply.
      # @option options [Symbol] :foreign_key Override the foreign key.
      # 
      def has_many(name, options = {})
        association_set.add(name, options)
      end
    end

    include Attributes
    include Scoping
    include Storage

    def update_attributes(attributes)
      self.attributes = attributes
      save
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
