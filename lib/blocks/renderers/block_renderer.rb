# frozen_string_literal: true

module Blocks
  class BlockRenderer < AbstractRenderer
    def render(runtime_context)
      render_item = runtime_context.render_item
      if render_item.is_a?(String) || render_item.respond_to?(:to_partial_path)
        output_buffer << partial_renderer.render(render_item, runtime_context, &runtime_context.runtime_block)

        # TODO: should the same approach be utilized for Procs & Methods?
        #  Can the capture method both invoke a method and pass a block to it?
      elsif render_item.is_a?(Proc)
        # TODO: should the runtime_context be the fire argument?
        args = runtime_context.runtime_args + [runtime_context]
        if runtime_context.runtime_block && runtime_context.runtime_block != render_item
          args = args.unshift runtime_context.runtime_block
        end
        output_buffer << capture(*args, &render_item)
      elsif render_item.is_a?(Method)
        # TODO: should the runtime_context be the fire argument?
        args = runtime_context.runtime_args + [runtime_context]
        if render_item.arity >= 0
          args = args[0, render_item.arity]
        end
        output_buffer << capture do
          render_item.call(*args, &runtime_context.runtime_block)
        end
      end
    end
  end
end