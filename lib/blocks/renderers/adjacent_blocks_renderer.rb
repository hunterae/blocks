module Blocks
  class AdjacentBlocksRenderer < AbstractRenderer
    def render(hook, runtime_context)
      hooks = hooks_for runtime_context.block_name, hook
      hooks = hooks.reverse if hook.to_s.index("before") == 0 || hook.to_s.index("prepend") == 0
      hooks.each do |hook_definition|
        hook_runtime_context = runtime_context.extend_from_definition(hook_definition, &hook_definition.runtime_block)
        output_buffer << block_with_hooks_renderer.render(hook_runtime_context)
      end
    end
  end
end