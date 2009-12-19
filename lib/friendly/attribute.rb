module Friendly
  class Attribute
    LITERALS = {}
    CONVERTERS = {}
    CONVERTERS[Integer] = lambda { |s| s.to_i }
    CONVERTERS[String]  = lambda { |s| s.to_s }
    
    attr_reader :klass, :name, :type, :default_value

    def initialize(klass, name, type, options = {})
      @klass         = klass
      @name          = name
      @type          = type
      @default_value = options[:default]
      build_accessors
    end

    def typecast(value)
      !type || value.is_a?(type) ? value : convert(value)
    end

    def convert(value)
      assert_converter_exists(value)
      CONVERTERS[type].call(value)
    end

    def default
      if !default_value.nil?
        default_value
      elsif type.respond_to?(:new)
        type.new
      else
        nil
      end
    end
    
    def self.register_type(type, literal, proc)
      LITERALS[type.name] = literal
      CONVERTERS[type] = proc
    end
      
    def self.literal(type)
      LITERALS[type.name]
    end
      
    protected
      def build_accessors
        n = name
        klass.class_eval do
          eval <<-__END__
            def #{n}=(value)
              @#{n} = self.class.attributes[:#{n}].typecast(value)
            end

            def #{n}
              @#{n} ||= self.class.attributes[:#{n}].default
            end
          __END__
        end
      end

      def assert_converter_exists(value)
        unless CONVERTERS.has_key?(type)
          msg = "Can't convert #{value} to #{type}. 
                 Add a custom converter to Friendly::Attribute::CONVERTERS."
          raise NoConverterExists, msg
        end
      end
  end
end
