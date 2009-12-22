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
        associations[args.first] = association_klass.new(*args)
      end

      def get_scope(name)
        get(name).scope
      end

      def get(name)
        associations[name]
      end
    end
  end
end
