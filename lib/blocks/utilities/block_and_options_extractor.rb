module Blocks
  class BlockAndOptionsExtractor
    attr_accessor :builder

    def initialize(builder)
      self.builder = builder
    end

    delegate :block_containers,
             :init_options,
             to: :builder

    def block_and_options_to_use(block_container_or_block_name, runtime_options=HashWithIndifferentAccess.new, &block)
      block_to_use = nil
      proxy_options = HashWithIndifferentAccess.new
      block_container_options = HashWithIndifferentAccess.new
      proxy_block = nil

      if block_container_or_block_name.is_a?(BlockContainer)
        block_container = block_container_or_block_name
        block_name = block_container.name
      else
        block_name = block_container_or_block_name
        block_container = block_containers[block_name]
      end

      if runtime_options.key?(:with) && runtime_options[:with]
        proxy_block = runtime_options.delete(:with)
        block_to_use, proxy_options = block_and_options_to_use(proxy_block, { block: block, proxy: true }.with_indifferent_access)
      end

      if block_container
        block_container_options = block_container

        if !proxy_block
          if block_container_options.key?(:with) && block_container_options[:with]
            proxy_block = block_container_options.delete(:with)
            block_to_use, proxy_options = block_and_options_to_use(proxy_block, { block: block || block_container.block, proxy: true }.with_indifferent_access)
          else
            block_to_use = block_container.block
          end
        end
      end

      if !block_to_use
        if !proxy_block
          block_to_use = block
        elsif builder.respond_to?(proxy_block)
          block_to_use = Proc.new do |*args|
            options = args.extract_options!
            block ||= options.delete(:block)
            builder.send(proxy_block, *args, options, &block)
          end
        end
      end

      proxy = runtime_options.delete(:proxy)
      runtime_defaults = (
        runtime_options.delete(:defaults) ||
        block_container_options.delete(:defaults)
      ).to_h.with_indifferent_access
      if proxy
        options_to_use = runtime_defaults.merge(block_container_options).merge(runtime_options)
      else
        options_to_use =
          Blocks.global_options.
                 merge(init_options).
                 merge(runtime_defaults).
                 merge(proxy_options).
                 merge(block_container_options).
                 merge(runtime_options)
      end

      [block_to_use, options_to_use]
    end
  end
end