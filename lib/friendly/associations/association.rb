module Friendly
  module Associations
    class Association
      attr_reader :owner_klass, :name, :scope_klass

      def initialize(owner_klass, name, scope_klass = Scope)
        @owner_klass = owner_klass
        @name        = name
        @scope_klass = scope_klass
      end

      def klass
        @klass ||= name.to_s.singularize.camelize.constantize
      end

      def foreign_key
        @foreign_key ||= [owner_klass_name, :id].join("_").to_sym
      end

      def owner_klass_name
        owner_klass.name.to_s.underscore.singularize
      end

      def scope(document)
        klass.scope(foreign_key => document.id)
      end
    end
  end
end
