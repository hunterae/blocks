module Blocks
  class NestingBlocksRenderer < AbstractRenderer
    def render(hook, runtime_context, &block)
      hooks = block_containers[runtime_context.block_name].hooks[hook]

      content_block = Proc.new { with_output_buffer { yield } }
      renderer = hooks.inject(content_block) do |inner_content, container|
        hook_runtime_context = runtime_context.context_for_block_container(container)
        Proc.new {
          with_output_buffer do
            render_block(inner_content, hook_runtime_context)
          end
        }
      end

      output_buffer << renderer.call
    end
  end
end