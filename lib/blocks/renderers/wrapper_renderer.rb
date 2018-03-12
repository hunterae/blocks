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
        runtime_context = runtime_context.extend_to_block_definition(block_definition, &content_block)
        block_renderer.render(runtime_context)
      elsif builder.respond_to?(wrapper)
        output_buffer << capture do
          builder.send(wrapper, runtime_context, &content_block)
        end
      else
        yield
      end
    end
  end
end