module Blocks
  class BlockWithHooksRenderer < AbstractRenderer

    def render(*args, &block)
      with_output_buffer do
        runtime_options = args.extract_options!
        block_name = args.shift
        options, block_name, block =
          merged_options_and_block_name_and_block_for(block_name, runtime_options, &block)
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
        options = args.extract_options!
        options = options.reverse_merge(block_container.runtime_options).reverse_merge(block_container.default_options)
        output_buffer << capture_block(wrapper_block, *args, options, &(block_container.block))
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
          output_buffer << PartialRenderer.new(builder).render(options.delete(:partial))
        end
      end
    end

    def block_container_and_block_name_and_block_for(block_name_or_block_container, &block)
      block_container = if block_name_or_block_container.is_a?(BlockContainer)
        block_name = block_name_or_block_container.name
        block_name_or_block_container
      else
        block_name = block_name_or_block_container
        block_containers[block_name_or_block_container]
      end

      [block_container, block_name, block_container.try(:block) || block]
    end

    def merged_options_and_block_name_and_block_for(block_name_or_block_container, runtime_options, &block)
      block_container, block_name, block =
        block_container_and_block_name_and_block_for(block_name_or_block_container, &block)

      proxy_block_container = runtime_options.delete(:with)
      if !proxy_block_container && block_container
        proxy_block_container = block_container.default_options.delete(:with) || block_container.runtime_options.delete(:with)
      end
      proxy_block_container = block_containers[proxy_block_container] if proxy_block_container

      options = Blocks.global_options.merge(init_options)
      options = options.merge(block_container.default_options) if block_container
      options = options.merge(runtime_options)
      if proxy_block_container
        options = options.merge(proxy_block_container.default_options).merge(proxy_block_container.runtime_options)
        options[:block] = block if block_given?
        block = proxy_block_container.block
      end
      options = options.merge(block_container.runtime_options) if block_container
      [options, block_name, block]
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
          options, block_name, block =
            merged_options_and_block_name_and_block_for(block_container, runtime_options)
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