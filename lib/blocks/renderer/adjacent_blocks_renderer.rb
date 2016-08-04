module Blocks
  class AdjacentBlocksRenderer < AbstractRenderer
    def render(hook, block_name, *args)
      runtime_options = args.extract_options!

      with_output_buffer do
        block_containers[block_name].hooks[hook].each do |block_container|
          options, block_name, block =
            merged_options_and_block_name_and_block_for(block_container, runtime_options)
          output_buffer << capture_block(*args, options, &(block_container.block))
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
        block = proxy_block_container.block
      end
      options = options.merge(block_container.runtime_options) if block_container
      [options, block_name, block]
    end
  end
end