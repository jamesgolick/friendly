module Friendly
  class Cache
    class ByID < Cache
      def store(document)
        cache.set(cache_key(document), document)
      end
      alias_method :create, :store
      alias_method :update, :store

      protected
        def cache_key(document)
          [klass.name, document.id.to_guid].join("/")
        end
    end
  end
end
