require 'friendly/attribute'
require 'friendly/config'
require 'friendly/data_store'
require 'friendly/document'
require 'friendly/index'
require 'friendly/persister'
require 'friendly/finder'
require 'friendly/repository'

module Friendly
  class << self
    def configure
    end

    def config
      @config ||= Config.new
    end
  end

  class Error < RuntimeError; end
  class RecordNotFound < Error; end
  class MissingIndex < Error; end
end
