module Friendly
  class Scope
    attr_reader :klass, :parameters

    def initialize(klass, parameters)
      @klass      = klass
      @parameters = parameters
    end

    def all(extra_parameters = {})
      klass.all(parameters.merge(extra_parameters))
    end

    def first(extra_parameters = {})
      klass.first(parameters.merge(extra_parameters))
    end
  end
end
