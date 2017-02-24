module Blocks
  class BlockWithHooksRenderer < AbstractRenderer
    def render(*args, &default_definition)
      with_output_buffer do
        runtime_context = RuntimeContext.new(builder, *args, &default_definition)

        if !runtime_context.skip_completely
          render_adjacent_blocks(BlockContainer::BEFORE_ALL, runtime_context)
          render_nesting_blocks(BlockContainer::AROUND_ALL, runtime_context) do
            render_wrapper(runtime_context.wrap_all, runtime_context) do
              render_collection(runtime_context) do |runtime_context|
                render_wrapper(runtime_context.wrap_each, runtime_context) do
                  render_nesting_blocks(BlockContainer::AROUND, runtime_context) do
                    render_adjacent_blocks(BlockContainer::BEFORE, runtime_context)
                    if !runtime_context.skip_content
                      render_wrapper(runtime_context.wrap_with, runtime_context) do
                        render_nesting_blocks(BlockContainer::SURROUND, runtime_context) do
                          render_adjacent_blocks(BlockContainer::PREPEND, runtime_context)
                          render_block(runtime_context)
                          render_adjacent_blocks(BlockContainer::APPEND, runtime_context)
                        end
                      end
                    end
                    render_adjacent_blocks(BlockContainer::AFTER, runtime_context)
                  end
                end
              end
            end
          end
          render_adjacent_blocks(BlockContainer::AFTER_ALL, runtime_context)
        end
      end
    end
  end
end