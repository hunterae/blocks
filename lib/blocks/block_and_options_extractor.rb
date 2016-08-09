module Blocks
  class BlockAndOptionsExtractor
    attr_accessor :builder

    def initialize(builder)
      self.builder = builder
    end

    delegate :block_containers,
             :init_options,
             to: :builder

    def block_and_options_to_use(block_name, runtime_options, &block)
      block_to_use = nil
      options_to_use = nil
      block_container_options = HashWithIndifferentAccess.new
      renders_with_proxy = false

      if runtime_options.key?(:with)
        renders_with_proxy = true
        block_to_use, options_to_use = block_and_options_to_use(runtime_options.delete(:with), HashWithIndifferentAccess.new, &block)
      end

      if builder.block_defined?(block_name)
        block_container = block_containers[block_name]
        block_container_options = block_container.merged_options

        if !renders_with_proxy && block_container_options.key?(:with)
          renders_with_proxy = true
          block_to_use, options_to_use = block_and_options_to_use(block_container_options.delete(:with), HashWithIndifferentAccess.new, &block)
        end
      end

      if !block_to_use
        block_to_use = block
      end

      options_to_use ||= Blocks.global_options.merge(init_options)
      options_to_use = options_to_use.merge(block_container_options).merge(runtime_options)

      [block_to_use, options_to_use]
    end
  end
end