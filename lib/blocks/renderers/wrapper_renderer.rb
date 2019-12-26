# frozen_string_literal: true

module Blocks
  class WrapperRenderer < AbstractRenderer
    def render(wrapper, wrapper_type, runtime_context)
      if wrapper.nil?
        yield

      elsif wrapper.is_a?(Proc)
        output_buffer << capture(
          Proc.new { with_output_buffer { yield } },
          *(runtime_context.runtime_args),
          runtime_context.merge(wrapper_type: wrapper_type),
          &wrapper
        )

      else
        runtime_context = runtime_context.extend_from_definition(wrapper, wrapper_type: wrapper_type) do
          with_output_buffer { yield }
        end
        output_buffer << block_with_hooks_renderer.render(runtime_context)
      end
    end
  end
end