module Blocks
  class NestingBlocksRenderer < AbstractRenderer
    def render(hook, block_name, *args, &block)
      around_block_containers = block_containers[block_name].hooks[hook]
      runtime_options = args.extract_options!

      content_block = Proc.new { with_output_buffer { yield } }
      renderer = around_block_containers.
        inject(content_block) do |inner_content, container|
          around_block, options = block_and_options_to_use(container, runtime_options)
          Proc.new { capture_block(inner_content, *args, options, &around_block) }
        end

      output_buffer << renderer.call
    end
  end
end