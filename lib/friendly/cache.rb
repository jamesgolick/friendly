require 'friendly/storage'

module Friendly
  class Cache < Storage
    attr_reader :klass, :fields, :cache

    def initialize(klass, fields, cache)
      @klass  = klass
      @fields = fields
      @cache  = cache
    end
  end
end
