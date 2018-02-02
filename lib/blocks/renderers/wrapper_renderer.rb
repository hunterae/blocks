module Blocks
  class WrapperRenderer < AbstractRenderer
    def render(wrapper, wrapper_type, runtime_context)
      content_block = Proc.new { with_output_buffer { yield } }
      runtime_context = runtime_context.merge(wrapper_type: wrapper_type)
      if wrapper.nil?
        yield
      elsif wrapper.is_a?(Proc)
        output_buffer << capture(content_block, *(runtime_context.runtime_args), runtime_context, &wrapper)
      elsif block_definition = block_for(wrapper)
        runtime_context = runtime_context.extend_to_block_definition(block_definition)
        block_renderer.render(content_block, runtime_context)
      elsif builder.respond_to?(wrapper)
        output_buffer << builder.send(wrapper, runtime_context, &content_block)
      else
        yield
      end

      # if wrapper
      #   inner_content = Proc.new { with_output_buffer { yield } }
      #   # wrapper_runtime_context = runtime_context.extend_to_wrapper(wrapper, wrapper_type, inner_content)
      #   output_buffer << block_with_hooks_renderer.render(
      #     wrapper_type: wrapper_type,
      #     with: wrapper,
      #     parent_runtime_context: runtime_context,
      #     &inner_content
      #   )
      #   # output_buffer << block_with_hooks_renderer.render(runtime_context)
      #   # debugger
      #   # block_renderer.render(wrapper_runtime_context)
      # else
      #   yield
      # end
    end
  end
end