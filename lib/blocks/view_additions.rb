module Blocks
  module ViewAdditions
    module ClassMethods
      def blocks
        return @blocks if @blocks
        @blocks = Blocks::Base.new(self)
        @blocks.blocks.merge! @controller_blocks.blocks if @controller_blocks
        @blocks
      end

      def call_if_proc(*args)
        Blocks::ProcWithArgs.call(*args)
      end

      def call_each_hash_value_if_proc(*args)
        Blocks::ProcWithArgs.call_each_hash_value(*args)
      end
    end
  end
end