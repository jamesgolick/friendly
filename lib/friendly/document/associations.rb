require 'friendly/associations'
require 'friendly/document/mixin'

module Friendly
  module Document
    module Associations
      extend Mixin

      module ClassMethods
        attr_writer :association_set

        def association_set
          @association_set ||= Friendly::Associations::Set.new(self)
        end

        # Add a has_many association.
        #
        # e.g.
        #
        #     class Post
        #       attribute :user_id, Friendly::UUID
        #       indexes   :user_id
        #     end
        #      
        #     class User
        #       has_many :posts
        #     end
        #     
        #     @user = User.create
        #     @post = @user.posts.create
        #     @user.posts.all == [@post] # => true
        #
        # _Note: Make sure that the target model is indexed on the foreign key. If it isn't, querying the association will raise Friendly::MissingIndex._
        #
        # Friendly defaults the foreign key to class_name_id just like ActiveRecord.
        # It also converts the name of the association to the name of the target class just like ActiveRecord does.
        #
        # The biggest difference in semantics between Friendly's has_many and active_record's is that Friendly's just returns a Friendly::Scope object. If you want all the associated objects, you have to call #all to get them. You can also use any other Friendly::Scope method.
        #
        # @param [Symbol] name The name of the association and plural name of the target class.
        # @option options [String] :class_name The name of the target class of this association if it is different than the name would imply.
        # @option options [Symbol] :foreign_key Override the foreign key.
        # 
        def has_many(name, options = {})
          association_set.add(name, options)
        end
      end
    end
  end
end
