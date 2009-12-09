module Friendly
  class Query
    attr_reader :conditions, :limit, :order

    def initialize(parameters)
      @conditions = parameters.reject { |k,v| k.to_s =~ /!$/ }
      @limit      = parameters[:limit!]
      @order      = parameters[:order!]
    end
  end
end
