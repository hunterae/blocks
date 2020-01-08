# frozen_string_literal: true

module Blocks
  class WrapperRenderer
    def self.render(wrapper, wrapper_type, runtime_context)
      output_buffer = runtime_context.output_buffer

      if wrapper.nil?
        yield

      elsif wrapper.is_a?(Proc)
        output_buffer << runtime_context.capture(
          Proc.new { runtime_context.with_output_buffer { yield } },
          *(runtime_context.runtime_args),
          runtime_context.to_hash.merge(wrapper_type: wrapper_type),
          &wrapper
        )

      else
        wrapper_runtime_context = runtime_context.extend_from_definition(
          wrapper,
          wrapper_type: wrapper_type
        ) do
          runtime_context.with_output_buffer { yield }
        end
        output_buffer << BlockWithHooksRenderer.render(wrapper_runtime_context)
      end
    end
  end
end