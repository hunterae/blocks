module Blocks
  class BlockWithHooksRenderer < AbstractRenderer
    def render(*args, &block)
      with_output_buffer do
        runtime_options = args.extract_options!
        block_name = args.shift
        # block, options = block_and_options_to_use(block_name, runtime_options, &block)
        block, options = BlockAndOptionsExtractor.new(builder).block_and_options_to_use(block_name, runtime_options, &block)
        # options, block_name, block =
        #   merged_options_and_block_name_and_block_for(block_name, runtime_options, &block)


        wrap_each = options.delete(:wrap_each) || options.delete(:wrap_with) || options.delete(:wrap) || options.delete(:wrapper)
        wrap_all = options.delete(:wrap_all)
        wrap_container_with = options.delete(:wrap_container_with)
        collection = options.delete(:collection)

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
      elsif builder.block_defined?(wrapper)
        block_container = block_containers[wrapper]
        options = block_container.merged_options.merge(args.extract_options!)
        if block_container.block
          output_buffer << capture_block(wrapper_block, *args, options, &(block_container.block))
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
      around_block_containers = block_containers[block_name].hooks[hook].clone
      runtime_options = args.extract_options!

      content_block = Proc.new do
        block_container = around_block_containers.shift
        if block_container
          # options, block_name, block =
          #   merged_options_and_block_name_and_block_for(block_container, runtime_options)
          # capture_block(content_block, *args, options, &(block_container.block))
          options = block_container.merged_options.merge(runtime_options)
          capture_block(content_block, *args, options, &(block_container.block))
        else
          with_output_buffer { yield }
        end
      end
      output_buffer << content_block.call
      # debugger if block_name == :content
      # output_buffer << SurroundingBlocksRenderer.new(builder).render(hook, block_name, *args, &block)
    end

    # Utility method to render either the before or after blocks for a partial block
    def render_adjacent_hooks_for(hook, block_name, *args)
      output_buffer << AdjacentBlocksRenderer.new(builder).render(hook, block_name, *args)
    end
  end
end