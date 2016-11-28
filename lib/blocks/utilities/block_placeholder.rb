module Blocks
  class BlockPlaceholder
    attr_accessor :block_container

    def initialize(block_container)
      self.block_container = block_container
    end

    def to_s
      "PLACEHOLDER_FOR_#{block_container.name} "
    end
  end
end