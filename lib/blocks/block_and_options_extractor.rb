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
      options_to_use = nil
      block_container_options = HashWithIndifferentAccess.new
      renders_with_proxy = false

      if block_container_or_block_name.is_a?(BlockContainer)
        block_container = block_container_or_block_name
        block_name = block_container.name
      else
        block_name = block_container_or_block_name
        block_container = if builder.block_defined?(block_name)
          block_containers[block_name]
        else
          nil
        end
      end

      if runtime_options.key?(:with)
        renders_with_proxy = true
        block_to_use, options_to_use = block_and_options_to_use(runtime_options.delete(:with), { block: block }.with_indifferent_access)
      end

      if block_container
        block_container_options = block_container.merged_options

        if !renders_with_proxy
          if block_container_options.key?(:with)
            renders_with_proxy = true
            block_to_use, options_to_use = block_and_options_to_use(block_container_options.delete(:with), { block: block }.with_indifferent_access)
          else
            block_to_use = block_container.block
          end
        end
      end

      if !block_to_use && !renders_with_proxy
        block_to_use = block
      end

      options_to_use ||= Blocks.global_options.merge(init_options)
      runtime_defaults = (runtime_options.delete(:defaults) || block_container_options.delete(:defaults)).to_h.with_indifferent_access
      options_to_use = options_to_use.merge(runtime_defaults).merge(block_container_options).merge(runtime_options)

      [block_to_use, options_to_use]
    end
  end
end