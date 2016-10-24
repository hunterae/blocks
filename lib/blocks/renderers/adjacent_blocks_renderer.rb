module Blocks
  class AdjacentBlocksRenderer < AbstractRenderer
    def render(hook, block_name, *args)
      runtime_options = args.extract_options!

      with_output_buffer do
        block_containers[block_name].hooks[hook].each do |block_container|
          block, options = block_and_options_to_use(block_container, runtime_options)
          output_buffer << capture_block(*args, options, &block) if block
        end
      end
    end
  end
end