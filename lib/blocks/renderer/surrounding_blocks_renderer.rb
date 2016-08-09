# TODO: FIX AND USE THIS
module Blocks
  class SurroundingBlocksRenderer < AbstractRenderer
    def render(hook, block_name, *args, &block)
      around_block_containers = block_containers[block_name].hooks[hook].clone
      runtime_options = args.extract_options!

      content_block = Proc.new do
        block_container = around_block_containers.shift
        if block_container
          options, block_name, block =
            merged_options_and_block_name_and_block_for(block_container, runtime_options)
          capture_block(content_block, *args, options, &(block_container.block))
        else
          with_output_buffer { yield }
        end
      end
      content_block.call
    end
  end
end