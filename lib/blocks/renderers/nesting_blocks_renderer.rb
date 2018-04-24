module Blocks
  class NestingBlocksRenderer < AbstractRenderer
    def render(hook, runtime_context)
      hooks = hooks_for(runtime_context.block_name, hook)
      if hooks.present?
        content_block = Proc.new { with_output_buffer { yield } }

        renderer = hooks.inject(content_block) do |inner_content, hook_definition|
          hook_runtime_context = runtime_context.extend_from_definition(hook_definition, &inner_content)
          Proc.new {
            block_with_hooks_renderer.render(hook_runtime_context)
          }
        end

        output_buffer << renderer.call
      else
        yield
      end

    end
  end
end