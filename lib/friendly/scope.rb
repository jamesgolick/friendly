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

    def build(extra_parameters = {})
      klass.new(params_without_modifiers(extra_parameters))
    end

    protected
      def params(extra)
        parameters.merge(extra)
      end

      def params_without_modifiers(extra)
        params(extra).reject { |k,v| k.to_s =~ /!$/ }
      end
  end
end
