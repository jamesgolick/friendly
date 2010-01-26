module Friendly
  class Indexer
    class << self
      attr_accessor :objects_per_iteration

      def populate(klass, *fields)
        instance.populate(klass, klass.storage_proxy.index_for_fields(fields))
      end

      def instance
        @instance ||= new
      end
    end

    self.objects_per_iteration = 100

    attr_reader :datastore, :translator

    def initialize(datastore  = Friendly.datastore, translator = Translator.new)
      @datastore  = datastore
      @translator = translator
    end

    def populate(klass, index)
      count  = 0
      loop do
        rows = datastore.all(klass, Query.new(:offset! => count, 
                                              :limit!  => objects_per_iteration, 
                                              :order!  => :added_id.asc))
        rows.each do |attrs|
          begin
            index.create(translator.to_object(klass, attrs))
          rescue Sequel::DatabaseError
            # we can safely swallow this exception because if we've gotten
            # to this point, we can be pretty sure that it's a duplicate
            # key error, which just means that the object already exists
            # in the index
          end
        end
        break if rows.length < objects_per_iteration
        count += objects_per_iteration
      end
    end

    protected
      def objects_per_iteration
        self.class.objects_per_iteration
      end
  end
end
