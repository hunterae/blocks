module Blocks
  class BlockPlaceholder
    attr_accessor :block_definition

    def initialize(block_definition)
      self.block_definition = block_definition
    end

    def to_s
      "PLACEHOLDER_FOR_#{block_definition.name} "
    end
  end
end