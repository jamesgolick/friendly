require 'set'

module Friendly
  # Provides attr accessors that track changes.
  #
  module ChangeTracking
    def self.included(klass)
      klass.send(:extend, ClassMethods)
    end

    module ClassMethods
      # Create a change tracking accessor.
      #
      # e.g.
      #     class Person
      #       include Friendly::ChangeTracking
      #
      #       change_tracking_accessor :name
      #     end
      #
      # This macro provides 5 methods for each accessor. Using :name as 
      # an example, they are:
      #
      #   name=            Set the name instance variable, keeping track 
      #                    of the original value.
      #   name             Get the current value of name.
      #   name_will_change Record the current value of name and indicate 
      #                    that it has changed. Used internally and useful
      #                    if you need to set the value of an instance variable
      #                    manually.
      #   name_changed?    Returns true or false based on whether the value has 
      #                    changed since instantiation or last reset.
      #   name_was         The value of the variable before the last change.
      #   
      def change_tracking_accessor(*names)
        names.each do |n|
          class_eval do
            eval <<-__END__
            def #{n}=(value)          # def name=(value)
              #{n}_will_change        #   name_will_change
              @#{n} = value           #   @name = value
            end                       # end

            def #{n}                  # def name
              @#{n}                   #   @name
            end                       # end

            def #{n}_will_change      # def name_will_change
              changed << :#{n}        #   changed << :name
              @#{n}_was = @#{n}       #   @name_was = @name
            end                       # end

            def #{n}_changed?         # def named_changed?
              changed.include?(:#{n}) #   changed.include?(:name)
            end                       # end

            def #{n}_was              # def name_was?
              @#{n}_was               #   @name_was
            end                       # end
            __END__
          end
        end
      end
    end

    # Have any of the attributes that are being tracked changed since last reset?
    #
    def changed?
      !changed.empty?
    end

    # Which attributes that are being tracked have changed since last reset?
    #
    def changed
      @changed ||= Set.new
    end

    # Reset all the changes to this object.
    #
    def reset_changes
      changed.each { |c| not_changed(c) }
    end

    # Reset the changed-ness of one attribute.
    #
    def not_changed(attribute)
      instance_variable_set(:"@#{attribute}_was", nil)
      changed.delete(attribute)
    end
  end
end
