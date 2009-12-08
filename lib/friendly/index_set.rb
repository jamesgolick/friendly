require 'set'

module Friendly
  class IndexSet < Set
    def first(conditions)
      index_for(conditions).first(conditions)
    end

    def all(conditions)
      index_for(conditions).all(conditions)
    end

    def index_for(conditions)
      index = detect { |i| i.satisfies?(conditions) }
      if index.nil?
        raise MissingIndex, "No index found to satisfy: #{conditions.inspect}."
      end
      index
    end
  end
end
