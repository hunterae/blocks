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
        if container && container.skip_content
          skip_content = true
          return if container.skip_all_hooks
        end

        render_adjacent_hooks_for(:before_all, block_name, *args, runtime_options)
        render_nesting_hooks_for(:around_all, block_name, *args, runtime_options) do

          render_wrapper(wrap_all, *args, options) do
            render_as_collection(collection, *args) do |*item_args|

              render_wrapper(wrap_each, *args, options) do
                render_nesting_hooks_for(:around, block_name, *item_args, runtime_options) do
                  render_adjacent_hooks_for(:before, block_name, *item_args, runtime_options)
                  if !skip_content
                    render_wrapper(wrap_with, *item_args, options) do
                      render_nesting_hooks_for(:surround, block_name, *item_args, runtime_options) do
                        # render_wrapper(wrap_with, *item_args, options) do
                          render_adjacent_hooks_for(:prepend, block_name, *item_args, runtime_options)
                          render_block(*item_args, options.merge(block_name: block_name), &block)
                          render_adjacent_hooks_for(:append, block_name, *item_args, runtime_options)
                        # end
                      end
                    end
                  end
                  render_adjacent_hooks_for(:after, block_name, *item_args, runtime_options)
                end
              end

            end
          end

        end
        render_adjacent_hooks_for(:after_all, block_name, *args, runtime_options)
      end
    end

    def render_wrapper(wrapper, *args, &block)
      wrapper_block = Proc.new { with_output_buffer { yield } }
      if wrapper.is_a?(Proc)
        output_buffer << call_with_params(wrapper, wrapper_block, *args)
      elsif wrapper.present?
        block, options = block_and_options_to_use(wrapper, args.extract_options!)
        if block
          output_buffer << capture_block(wrapper_block, *args, options, &block)
        elsif builder.respond_to?(wrapper)
          output_buffer << builder.send(wrapper, *args, options, &wrapper_block)
        else
          yield
        end
      else
        yield
      end
    end

    def render_block(*args, &block)
      if block_given?
        output_buffer << capture_block(*args, &block)
      else
        options = args.extract_options!
        if options[:partial]
          output_buffer << PartialRenderer.new(builder).render(options.delete(:partial), options, &block)
        end
      end
    end

    def render_as_collection(collection, *args, &block)
      if collection
        collection.each do |item|
          yield *([item] + args)
        end
      else
        yield *args
      end
    end

    def render_nesting_hooks_for(hook, block_name, *args, &block)
      output_buffer << SurroundingBlocksRenderer.new(builder).render(hook, block_name, *args, &block)
    end

    # Utility method to render either the before or after blocks for a partial block
    def render_adjacent_hooks_for(hook, block_name, *args)
      output_buffer << AdjacentBlocksRenderer.new(builder).render(hook, block_name, *args)
    end
  end
end