module Blocks
  class BlockRenderer < AbstractRenderer
    def render(*args, runtime_context)
      render_item = runtime_context.render_item
      if render_item.is_a?(String) || render_item.respond_to?(:to_partial_path)
        output_buffer << partial_renderer.render(render_item, runtime_context)
      elsif render_item.is_a?(Proc)
        args = args + runtime_context.runtime_args
        output_buffer << capture(*args, runtime_context, &render_item)
      end
    end
  end
end