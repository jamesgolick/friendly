module Friendly
  class Scope
    attr_reader :klass, :parameters

    def initialize(klass, parameters)
      @klass      = klass
      @parameters = parameters
    end

    def all(extra_parameters = {})
      klass.all(params(extra_parameters))
    end

    def first(extra_parameters = {})
      klass.first(params(extra_parameters))
    end

    def paginate(extra_parameters = {})
      klass.paginate(params(extra_parameters))
    end

    protected
      def params(extra)
        parameters.merge(extra)
      end
  end
end
