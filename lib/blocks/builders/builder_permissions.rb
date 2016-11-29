module Blocks
  module BuilderPermissions
    extend ActiveSupport::Concern

    METHODS_TO_PROTECT = [:render, :define, :deferred_render, :replace, :skip]

    included do
      attr_writer :permitted_blocks
      attr_accessor :allow_all_blocks
      attr_accessor :allow_anonymous_blocks

      METHODS_TO_PROTECT.each do |method_name|
        alias_method "original_#{method_name}", method_name
        define_method(method_name) do |*args, &block|
          if permitted?(args.first)
            self.send("original_#{method_name}", *args, &block)
          else
            InvalidPermissionsHandler.build(method_name, args.first)
          end
        end
      end
    end

    def restrict_blocks
      self.allow_all_blocks = false
    end

    def permitted_blocks
      @permitted_blocks ||= []
    end

    def permit(*names)
      self.permitted_blocks += names
    end

    def permit_all
      self.allow_all_blocks = true
    end

    def permit_anonymous_blocks
      self.allow_anonymous_blocks = true
    end

    def permitted?(name)
      allow_all_blocks ||
      (block_containers[name].try(:anonymous) && allow_anonymous_blocks) ||
      !name.respond_to?(:to_sym) ||
      permitted_blocks.any? {|e| e.to_sym == name.to_sym }
    end
  end
end