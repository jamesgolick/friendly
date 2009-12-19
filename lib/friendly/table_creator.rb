module Friendly
  class TableCreator
    attr_reader :db

    def initialize(db = Friendly.db)
      @db = db
    end

    def create(table)
      unless db.table_exists?(table.table_name)
        case table
        when DocumentTable
          create_document_table(table) 
        when Index
          create_index_table(table)
        end
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

      def create_index_table(table)
        db.create_table(table.table_name) do
          binary :id, :size => 16
          table.fields.flatten.each do |f|    
            # Support for custom types        
            if literal = Friendly::Attribute.sql_type(table.klass.attributes[f].type)
              column(f, literal)
            else
              method(table.klass.attributes[f].type.name.to_sym).call(f)
            end        
          end
          primary_key table.fields.flatten + [:id]
          unique :id
        end
      end
  end
end

