require 'active_support/inflector'
require 'friendly/document/associations'
require 'friendly/document/attributes'
require 'friendly/document/convenience'
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
      attr_writer :table_name

      def table_name
        @table_name ||= name.pluralize.underscore
      end
    end

    include Associations
    include Convenience
    include Scoping
    include Storage
    include Attributes

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
  end
end
