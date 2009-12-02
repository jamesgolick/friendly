module Friendly
  module Document
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end

    module ClassMethods
      def property(*args); end
    end

    def initialize(*args); end

    def save
      Friendly.config.repository.save(self)
    end
  end
end
