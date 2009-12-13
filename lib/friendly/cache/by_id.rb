module Friendly
  class Cache
    class ByID < Cache
      def store(document)
        cache.set(cache_key(document.id), document)
      end
      alias_method :create, :store
      alias_method :update, :store

      def first(query)
        cache.get(cache_key(query.conditions[:id]))
      end

      protected
        def cache_key(id)
          [klass.name, id.to_guid].join("/")
        end
    end
  end
end
