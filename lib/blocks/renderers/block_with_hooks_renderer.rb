module Blocks
  class BlockWithHooksRenderer < AbstractRenderer
    def render(*args, &default_definition)
      with_output_buffer do
        runtime_options = args.extract_options!
        block_name = args.shift
        block, options = block_and_options_to_use(block_name, runtime_options, &default_definition)
        wrap_all = options.delete(:wrap_all)
        wrap_each = options.delete(:wrap_each)
        wrap_with = options.delete(:wrap_with) || options.delete(:wrap) || options.delete(:wrapper)
        collection = options.delete(:collection)
        runtime_options = runtime_options.except(:wrap_each, :wrap_with, :wrap, :wrapper, :wrap_all, :wrap_container_with, :collection)

        container = block_containers[block_name] if block_name
        skip_content = container.try(:skip_content)
        return if container.try(:skip_completely)

        render_adjacent_hooks_for(BlockContainer::BEFORE_ALL, block_name, *args, runtime_options)
        render_nesting_hooks_for(BlockContainer::AROUND_ALL, block_name, *args, runtime_options) do
          render_wrapper(wrap_all, *args, options) do
            render_as_collection(collection, *args, options) do |*item_args, options|
              render_wrapper(wrap_each, *item_args, options) do
                render_nesting_hooks_for(BlockContainer::AROUND, block_name, *item_args, runtime_options) do
                  render_adjacent_hooks_for(BlockContainer::BEFORE, block_name, *item_args, runtime_options)
                  if !skip_content
                    render_wrapper(wrap_with, *item_args, options) do
                      render_nesting_hooks_for(BlockContainer::SURROUND, block_name, *item_args, runtime_options) do
                        render_adjacent_hooks_for(BlockContainer::PREPEND, block_name, *item_args, runtime_options)
                        render_block(*item_args, options.merge(block_name: block_name), &block)
                        render_adjacent_hooks_for(BlockContainer::APPEND, block_name, *item_args, runtime_options)
                      end
                    end
                  end
                  render_adjacent_hooks_for(BlockContainer::AFTER, block_name, *item_args, runtime_options)
                end
              end
            end
          end
        end
        render_adjacent_hooks_for(BlockContainer::AFTER_ALL, block_name, *args, runtime_options)
      end
    end

    protected
    def render_wrapper(wrapper, *args, &block)
      wrapper_renderer.render(wrapper, *args, &block)
    end

    def render_block(*args, &block)
      block_renderer.render(*args, &block)
    end

    def render_as_collection(collection, *args, &block)
      collection_renderer.render(collection, *args, &block)
    end

    def render_nesting_hooks_for(hook, block_name, *args, &block)
      nesting_blocks_renderer.render(hook, block_name, *args, &block)
    end

    def render_adjacent_hooks_for(hook, block_name, *args)
      adjacent_blocks_renderer.render(hook, block_name, *args)
    end
  end
end