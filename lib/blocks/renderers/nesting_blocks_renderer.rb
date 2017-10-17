module Blocks
  class NestingBlocksRenderer < AbstractRenderer
    def render(hook, runtime_context)
      block = block_for(runtime_context.block_name)
      hooks = block.try(:hooks_for, hook)
      if hooks.present?
        content_block = Proc.new { with_output_buffer { yield } }

        renderer = hooks.inject(content_block) do |inner_content, hook_definition|
          hook_runtime_context = runtime_context.extend_to_block_definition(hook_definition)
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