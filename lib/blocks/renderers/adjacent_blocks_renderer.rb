# frozen_string_literal: true

module Blocks
  class AdjacentBlocksRenderer
    def self.render(hook, runtime_context)
      hooks = runtime_context.hooks_for hook
      if hooks.present?
        output_buffer = runtime_context.output_buffer
        hooks = hooks.reverse if hook.to_s.index("before") == 0 || hook.to_s.index("prepend") == 0
        hooks.each do |hook_definition|
          hook_runtime_context = runtime_context.extend_from_definition(hook_definition, &hook_definition.runtime_block)
          output_buffer << BlockWithHooksRenderer.render(hook_runtime_context)
        end
      end
    end
  end
end