# TODO: FIX AND USE THIS
module Blocks
  class SurroundingBlocksRenderer < AbstractRenderer
    def render(hook, block_name, *args, &block)
      around_block_containers = block_containers[block_name].hooks[hook].clone
      runtime_options = args.extract_options!

      content_block = Proc.new do
        block_container = around_block_containers.shift
        if block_container
          block, options = block_and_options_to_use(block_container, runtime_options)
          # if block
          capture_block(content_block, *args, options, &block)
          # else
          #   output_buffer << with_output_buffer { yield }
          # end
        else
          with_output_buffer { yield }
        end
      end
      content_block.call
    end
  end
end