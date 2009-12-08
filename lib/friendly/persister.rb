module Friendly
  class Persister
    attr_reader :datastore, :translator

    def initialize(datastore, translator = Translator.new)
      @datastore  = datastore
      @translator = translator
    end

    def save(document)
      document.new_record? ? create(document) : update(document)
    end

    def create(document)
      record = translator.to_record(document)
      id     = datastore.insert(document, record)
      update_document(document, record.merge(:id => id))
      document.indexes.create(document)
    end

    def update(document)
      record = translator.to_record(document)
      datastore.update(document, document.id, record)
      update_document(document, record)
      document.indexes.update(document)
    end

    protected
      def update_document(document, record)
        document.attributes = record.reject { |k,v| k == :attributes }
      end
  end
end
