module BuildingBlocks
  module ViewAdditions
    module ClassMethods
      def blocks
        @blocks ||= BuildingBlocks::Base.new(self)
      end
      alias bb blocks
      alias buildingblocks blocks
      alias building_blocks blocks
    end
  end
end