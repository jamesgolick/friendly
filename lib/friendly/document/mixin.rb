module Friendly
  module Document
    module Mixin
      # FIXME: I'm not in love with this. But, I also don't think it's the
      # end of the world.
      def included(klass)
        klass.const_get(:ClassMethods).send(:include, self.const_get(:ClassMethods))
      end
    end
  end
end
