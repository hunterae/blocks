module Blocks
  class WrapperRenderer < AbstractRenderer
    def render(wrapper, runtime_context, &block)
      content_block = Proc.new { with_output_buffer { yield } }
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
    end
  end
end