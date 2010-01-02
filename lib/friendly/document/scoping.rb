require 'friendly/document/mixin'

module Friendly
  module Document
    module Scoping
      extend Mixin

      module ClassMethods
        attr_writer :scope_proxy
        
        def scope_proxy
          @scope_proxy ||= ScopeProxy.new(self)
        end

        # Add a named scope to this Document.
        #
        # e.g.
        #     
        #     class Post
        #       indexes     :created_at
        #       named_scope :recent, :order! => :created_at.desc
        #     end
        #
        # Then, you can access the recent posts with:
        #
        #     Post.recent.all
        # ...or...
        #     Post.recent.first
        #
        # Both #all and #first also take additional parameters:
        #
        #     Post.recent.all(:author_id => @author.id)
        #
        # Scopes are also chainable. See the README or Friendly::Scope docs for details.
        #
        # @param [Symbol] name the name of the scope.
        # @param [Hash] parameters the query that this named scope will perform.
        #
        def named_scope(name, parameters)
          scope_proxy.add_named(name, parameters)
        end

        # Returns boolean based on whether the Document has a scope by a particular name.
        #
        # @param [Symbol] name The name of the scope in question.
        #
        def has_named_scope?(name)
          scope_proxy.has_named_scope?(name)
        end

        # Create an ad hoc scope on this Document.
        #
        # e.g.
        #     
        #     scope = Post.scope(:order! => :created_at)
        #     scope.all # => [#<Post>, #<Post>]
        #
        # @param [Hash] parameters the query parameters to create the scope with.
        #
        def scope(parameters)
          scope_proxy.ad_hoc(parameters)
        end
      end
    end
  end
end
