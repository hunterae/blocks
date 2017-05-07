module Blocks
  class NestingBlocksRenderer < AbstractRenderer
    def render(hook, runtime_context, &block)
      hooks = block_definitions[runtime_context.block_name].hooks_for hook
      content_block = Proc.new { with_output_buffer { yield } }
      renderer = hooks.inject(content_block) do |inner_content, block_definition|
        hook_runtime_context = runtime_context.extend_to_block_definition(block_definition)
        Proc.new {
          with_output_buffer do
            block_renderer.render(inner_content, hook_runtime_context)
          end
        }
      end

      output_buffer << renderer.call
    end
  end
end