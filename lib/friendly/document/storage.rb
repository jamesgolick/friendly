require 'friendly/document/mixin'

module Friendly
  module Document
    module Storage
      extend Mixin

      module ClassMethods
        attr_writer :storage_proxy, :query_klass
        
        def create_tables!
          storage_proxy.create_tables!
        end

        def storage_proxy
          @storage_proxy ||= StorageProxy.new(self)
        end

        def indexes(*args)
          storage_proxy.add(args)
        end

        def caches_by(*fields)
          options = fields.last.is_a?(Hash) ? fields.pop : {}
          storage_proxy.cache(fields, options)
        end

        def first(query)
          storage_proxy.first(query(query))
        end

        def all(query)
          storage_proxy.all(query(query))
        end

        def count(conditions)
          storage_proxy.count(query(conditions))
        end

        def query_klass
          @query_klass ||= Query
        end

        protected
          def query(conditions)
            conditions.is_a?(Query) ? conditions : query_klass.new(conditions)
          end
      end
      
      def save
        new_record? ? storage_proxy.create(self) : storage_proxy.update(self)
      end

      def destroy
        storage_proxy.destroy(self)
      end

      def storage_proxy
        self.class.storage_proxy
      end
    end
  end
end
