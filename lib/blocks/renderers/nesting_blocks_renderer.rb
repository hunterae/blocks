# frozen_string_literal: true

module Blocks
  class NestingBlocksRenderer
    def self.render(hook, runtime_context)
      hooks = runtime_context.hooks_for(hook)
      if hooks.present?
        content_block = Proc.new { runtime_context.with_output_buffer { yield } }

        renderer = hooks.inject(content_block) do |inner_content, hook_definition|
          hook_runtime_context = runtime_context.extend_from_definition(hook_definition, &inner_content)
          Proc.new {
            BlockWithHooksRenderer.render(hook_runtime_context)
          }
        end

        runtime_context.output_buffer << renderer.call
      else
        yield
      end
    end
  end
end