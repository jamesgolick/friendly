require 'friendly/named_scope'

module Friendly
  class ScopeProxy
    attr_reader :klass, :named_scope_klass, :scopes

    def initialize(klass, named_scope_klass = NamedScope)
      @klass             = klass
      @named_scope_klass = named_scope_klass
      @scopes            = {}
    end

    def add(name, parameters)
      scopes[name] = named_scope_klass.new(klass, parameters)
      add_scope_method_to_klass(name)
    end

    def get(name)
      scopes[name]
    end

    def get_instance(name)
      get(name).scope
    end

    protected
      def add_scope_method_to_klass(scope_name)
        klass.class_eval do
          eval <<-__END__
            def self.#{scope_name}
              scope_proxy.get_instance(:#{scope_name})
            end
          __END__
        end
      end
  end
end
