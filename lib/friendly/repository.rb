require 'active_support/core_ext/hash'
require 'active_support/core_ext/module'

module Friendly
  class Repository
    attr_reader :finder, :persister

    def initialize(finder, persister)
      @finder    = finder
      @persister = persister
    end

    def save(doc)
      persister.save(doc)
    end

    def find(klass, *ids)
      finder.find(klass, *ids)
    end
  end
end
