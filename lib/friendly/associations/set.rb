module Friendly
  module Associations
    class Set
      attr_reader :klass, :association_klass, :associations

      def initialize(klass, association_klass = Association)
        @klass             = klass
        @association_klass = association_klass
        @associations      = {}
      end

      def add(*args)
        associations[args.first] = association_klass.new(klass, *args)
        add_association_accessor(args.first)
      end

      def get_scope(name)
        get(name).scope
      end

      def get(name)
        associations[name]
      end

      protected
        def add_association_accessor(name)
          klass.class_eval do
            eval <<-__END__
            def #{name}
              self.class.association_set.get_scope(:#{name})
            end
            __END__
          end
        end
    end
  end
end
