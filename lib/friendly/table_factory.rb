module Friendly
  class TableFactory
    attr_reader :doc_table_klass, :index_klass

    def initialize(doc_table_klass = DocumentTable, index_klass = Index)
      @doc_table_klass = doc_table_klass
      @index_klass     = index_klass
    end

    def document_table(*args)
      doc_table_klass.new(*args)
    end

    def index(*args)
      index_klass.new(*args)
    end
  end
end
