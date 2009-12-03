module Friendly
  class DataStore
    attr_reader :database

    def initialize(database)
      @database = database
    end

    def insert(insertable_type, attributes)
      database.from(insertable_type.table_name).insert(attributes)
    end
  end
end
