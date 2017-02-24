module Blocks
  class AdjacentBlocksRenderer < AbstractRenderer
    def render(hook, runtime_context)
      hooks = block_containers[runtime_context.block_name].hooks[hook]
      hooks = hooks.reverse if hook.to_s.index("before") == 0 || hook.to_s.index("prepend") == 0
      hooks.each do |block_container|
        hook_runtime_context = runtime_context.context_for_block_container(block_container)
        render_block(hook_runtime_context)
      end
    end
  end
end