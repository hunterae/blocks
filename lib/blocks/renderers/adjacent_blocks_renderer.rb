module Blocks
  class AdjacentBlocksRenderer < AbstractRenderer
    def render(hook, runtime_context)
      hooks = block_definitions[runtime_context.block_name].hooks_for hook
      hooks = hooks.reverse if hook.to_s.index("before") == 0 || hook.to_s.index("prepend") == 0
      hooks.each do |block_definition|
        hook_runtime_context = runtime_context.extend_to_block_definition(block_definition)
        block_renderer.render(hook_runtime_context)
      end
    end
  end
end