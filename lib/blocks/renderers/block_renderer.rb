# frozen_string_literal: true

module Blocks
  class BlockRenderer
    def self.render(runtime_context)
      output_buffer = runtime_context.output_buffer
      render_item = runtime_context.render_item
      # TODO: should convert anything that passes a runtime context back to the user to a normal hash
      if render_item.is_a?(String) || render_item.respond_to?(:to_partial_path)
        output_buffer << PartialRenderer.render(runtime_context)

        # TODO: should the same approach be utilized for Procs & Methods?
        #  Can the capture method both invoke a method and pass a block to it?
      elsif render_item.is_a?(Proc)
        # TODO: should the runtime_context be the first argument?
        args = runtime_context.runtime_args + [runtime_context.to_hash]
        if runtime_context.runtime_block && runtime_context.runtime_block != render_item
          args = args.unshift runtime_context.runtime_block
        end
        output_buffer << runtime_context.capture(*args, &render_item)

      elsif render_item.is_a?(Method)
        # TODO: should the runtime_context be the first argument?
        args = runtime_context.runtime_args + [runtime_context.to_hash]
        if render_item.arity >= 0
          args = args[0, render_item.arity]
        end
        output_buffer << runtime_context.capture do
          render_item.call(*args, &runtime_context.runtime_block)
        end
      end
    end
  end
end