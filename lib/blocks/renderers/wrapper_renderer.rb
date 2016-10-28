module Blocks
  class WrapperRenderer < AbstractRenderer
    def render(wrapper, *args, &block)
      content_block = Proc.new { with_output_buffer { yield } }
      if wrapper.is_a?(Proc)
        output_buffer << capture_block(content_block, *args, &wrapper)
      elsif wrapper.present?
        wrapper_block, options = block_and_options_to_use(wrapper, args.extract_options!)
        if wrapper_block
          output_buffer << capture_block(content_block, *args, options, &wrapper_block)
        elsif builder.respond_to?(wrapper)
          output_buffer << builder.send(wrapper, *args, options, &content_block)
        else
          yield
        end
      else
        yield
      end
    end
  end
end