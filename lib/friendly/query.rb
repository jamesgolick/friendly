module Friendly
  class Query
    attr_reader :conditions, :limit, :order, :preserve_order

    def initialize(parameters)
      @conditions     = parameters.reject { |k,v| k.to_s =~ /!$/ }
      @limit          = parameters[:limit!]
      @order          = parameters[:order!]
      @preserve_order = parameters[:preserve_order!]
    end

    def preserve_order?
      preserve_order
    end
  end
end
