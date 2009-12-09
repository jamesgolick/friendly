module Friendly
  class Query
    attr_reader :conditions, :limit

    def initialize(parameters)
      @conditions = parameters.reject { |k,v| k.to_s =~ /!$/ }
      @limit      = parameters[:limit!]
    end
  end
end
