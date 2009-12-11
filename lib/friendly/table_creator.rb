module Friendly
  class TableCreator
    attr_reader :db

    def initialize(db = Friendly.db)
      @db = db
    end

    def create(table)
      case table
      when DocumentTable
        create_document_table(table)
      end
    end

    protected
      def create_document_table(table)
        db.create_table(table.table_name) do
          primary_key :added_id
          binary      :id,         :size => 16
          String      :attributes, :text => true
          Time        :created_at
          Time        :updated_at
        end
      end
  end
end

