module Friendly
  class Query
    attr_reader :conditions, :limit, :order, :preserve_order, :offset, :uuid_klass

    def initialize(parameters, uuid_klass = UUID)
      @uuid_klass     = uuid_klass
      @conditions     = parameters.reject { |k,v| k.to_s =~ /!$/ }
      @limit          = parameters[:limit!]
      @order          = parameters[:order!]
      @preserve_order = parameters[:preserve_order!]
      @offset         = parameters[:offset!]
      convert_ids_to_uuids
    end

    def preserve_order?
      preserve_order
    end

    def offset?
      offset
    end

    protected
      def convert_ids_to_uuids
        if conditions[:id] && conditions[:id].is_a?(Array)
          conditions[:id] = conditions[:id].map { |i| uuid_klass.new(i) }
        elsif conditions[:id]
          conditions[:id] = uuid_klass.new(conditions[:id])
        end
      end
  end
end
