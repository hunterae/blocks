module Blocks
  module ViewAdditions
    module ClassMethods
      def blocks
        return @blocks if @blocks
        @blocks = Blocks::Base.new(self)
        @blocks.blocks.merge! @controller_blocks.blocks if @controller_blocks
        @blocks
      end
    end
  end
end