module Friendly
  # placeholder that represents a boolean
  # since ruby has no boolean superclass
  class Boolean
    def initialize(value)
      @value = value
    end    
    
    def sql_literal(dataset)
      dataset.literal(to_s)    
    end
    
    def to_s
      @value ? "'t'"  : "'f'"
    end
  end
end

class FriendlyBoolean < Friendly::Boolean; end
