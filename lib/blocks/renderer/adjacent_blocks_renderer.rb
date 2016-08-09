module Blocks
  class AdjacentBlocksRenderer < AbstractRenderer
    def render(hook, block_name, *args)
      runtime_options = args.extract_options!

      with_output_buffer do
        block_containers[block_name].hooks[hook].each do |block_container|
          # options, block_name, block =
            # merged_options_and_block_name_and_block_for(block_container, runtime_options)
          options = block_container.merged_options.merge(runtime_options)
          output_buffer << capture_block(*args, options, &(block_container.block))
        end
      end
    end
  end
end