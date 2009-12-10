require 'friendly/attribute'
require 'friendly/config'
require 'friendly/data_store'
require 'friendly/document'
require 'friendly/document_table'
require 'friendly/index'
require 'friendly/query'
require 'friendly/storage_proxy'
require 'friendly/translator'
require 'friendly/uuid'

module Friendly
  class << self
    attr_accessor :datastore

    def batch
      begin
        datastore.start_batch
        yield
        datastore.flush_batch
      ensure
        datastore.reset_batch
      end
    end
  end

  class Error < RuntimeError; end
  class RecordNotFound < Error; end
  class MissingIndex < Error; end
  class NoConverterExists < Friendly::Error; end
end
