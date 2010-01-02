require 'friendly/document/mixin'

module Friendly
  module Document
    module Convenience
      extend Mixin

      module ClassMethods
        attr_writer :collection_klass
        
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
      end

      def update_attributes(attributes)
        self.attributes = attributes
        save
      end
    end
  end
end
