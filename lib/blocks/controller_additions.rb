module Blocks
  module ControllerAdditions
    module ClassMethods
      def blocks
        @controller_blocks ||= Blocks::Base.new(view_context)
      end
    end
  end
end