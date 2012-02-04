module BuildingBlocks
  module ViewAdditions
    module ClassMethods
      def blocks
        @blocks ||= BuildingBlocks::Base.new(self)
      end
    end
  end
end

if defined?(ActionView::Base)
  ActionView::Base.send :include, BuildingBlocks::ViewAdditions::ClassMethods
end