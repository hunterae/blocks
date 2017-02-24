module Blocks
  class BlockRenderer < AbstractRenderer
    def render(*args, runtime_context)
      render_item = runtime_context.render_item
      if render_item.is_a?(String)
        output_buffer << render_partial(runtime_context.render_item, runtime_context)
      elsif render_item.is_a?(Proc)
        args = args + runtime_context.runtime_args
        output_buffer << capture_block(*args, runtime_context, &render_item)
      end
    end
  end
end