require 'friendly/storage'

module Friendly
  class Cache < Storage
    class << self
      def cache_for(klass, fields)
        unless fields == [:id]
          raise NotSupported, "Caching is only possible by id at the moment."
        end

        ByID.new(klass, fields)
      end
    end

    attr_reader :klass, :fields, :cache

    def initialize(klass, fields, cache = Friendly.cache)
      @klass  = klass
      @fields = fields
      @cache  = cache
    end
  end
end
