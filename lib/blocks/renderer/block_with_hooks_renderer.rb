module Blocks
  class BlockWithHooksRenderer < AbstractRenderer
    def render(*args, &default_definition)
      with_output_buffer do
        runtime_options = args.extract_options!
        block_name = args.shift
        block, options = block_and_options_to_use(block_name, runtime_options, &default_definition)

        wrap_each = options.delete(:wrap_each) || options.delete(:wrap_with) || options.delete(:wrap) || options.delete(:wrapper)
        wrap_all = options.delete(:wrap_all)
        wrap_container_with = options.delete(:wrap_container_with)
        collection = options.delete(:collection)
        runtime_options = runtime_options.except(:wrap_each, :wrap_with, :wrap, :wrapper, :wrap_all, :wrap_container_with, :collection)

        skip_block = false
        if block_name && builder.skipped_blocks.key?(block_name)
          skip_block = true
          return if builder.skipped_blocks[block_name][:skip_all_hooks]
        end

        render_adjacent_hooks_for(:before_all, block_name, *args, runtime_options)
        render_nesting_hooks_for(:around_all, block_name, *args, runtime_options) do

          render_wrapper(wrap_all, *args, options) do
            render_as_collection(collection, *args) do |*item_args|

              render_wrapper(wrap_container_with, *args, options) do
                render_adjacent_hooks_for(:before, block_name, *item_args, runtime_options)
                if !skip_block
                  render_nesting_hooks_for(:around, block_name, *item_args, runtime_options) do
                    render_wrapper(wrap_each, *item_args, options) do
                      render_adjacent_hooks_for(:prepend, block_name, *item_args, runtime_options)
                      render_block(*item_args, options, &block)
                      render_adjacent_hooks_for(:append, block_name, *item_args, runtime_options)
                    end

                  end
                end
                render_adjacent_hooks_for(:after, block_name, *item_args, runtime_options)
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