module Blocks
  class NestingBlocksRenderer < AbstractRenderer
    def render(hook, runtime_context, &block)
      block = block_for(runtime_context.block_name)
      if block
        content_block = Proc.new { with_output_buffer { yield } }
        hooks = block.hooks_for(hook)

        renderer = hooks.inject(content_block) do |inner_content, block_definition|
          hook_runtime_context = runtime_context.extend_to_block_definition(block_definition)
          Proc.new {
            with_output_buffer do
              block_renderer.render(inner_content, hook_runtime_context)
            end
          }
        end

        output_buffer << renderer.call
      else
        yield
      end
    end
  end
end