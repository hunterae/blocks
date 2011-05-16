module BuildingBlocks
  module HelperMethods
    def blocks
      @blocks ||= BuildingBlocks::Base.new(self)
    end
  end
end
