require 'memcached'

module Friendly
  class Memcached
    attr_reader :cache

    def initialize(cache)
      @cache = cache
    end

    def set(key, value)
      @cache.set(key, value)
    end

    def get(key)
      @cache.get(key)
    rescue ::Memcached::NotFound
      if block_given?
        value = yield
        @cache.set(key, value)
        value
      end
    end

    def multiget(keys)
      hits         = @cache.get(keys)
      missing_keys = keys - hits.keys

      if !missing_keys.empty? && block_given?
        missing_keys.each do |missing_key|
          value = yield(missing_key)
          cache.set(missing_key, value)
          hits.merge!(missing_key => value)
        end
      end

      hits
    end

    def delete(key)
      cache.delete(key)
    rescue ::Memcached::NotFound
    end
  end
end
