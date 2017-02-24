module Blocks
  class RuntimeContext < RenderingStrategy
    CONTROL_VARIABLES = {
      wrap_all: [],
      wrap_each: [:outer_wrapper],
      wrap_with: [:wrap, :wrapper, :inner_wrapper],
      collection: [],
      defaults: [],
      as: []
    }

    ATTRIBUTES = [
      :block_name,
      :block_container,
      :runtime_block,
      :builder,
      :render_item,
      :runtime_args
    ] + CONTROL_VARIABLES.keys
    attr_accessor(*ATTRIBUTES)

    delegate :skip_content, :skip_completely, to: :block_container
    delegate :block_containers, :init_options, to: :builder

    def initialize_copy(original)
      super
      self.callers = original.callers.clone
    end

    alias_method :dup, :clone

    def initialize(builder, *runtime_args, &runtime_block)
      super(&nil)
      add_options "Runtime", runtime_args.extract_options!
      self.builder = builder
      block_container_or_block_name = runtime_args.shift
      self.runtime_args = runtime_args

      self.block_name, self.block_container = if block_container_or_block_name.is_a?(BlockContainer)
        [block_container.name, block_container_or_block_name]
      else
        [block_container_or_block_name, block_containers[block_container_or_block_name]]
      end
      self.runtime_block = runtime_block
      add_options block_container.name, block_container

      extract_render_strategy
      extract_control_options
    end

    def context_for_block_container(block_container)
      RuntimeContext.new(builder).tap do |runtime_context|
        runtime_context.add_options block_container
        runtime_context.add_options self
        runtime_context.extract_render_strategy
        runtime_context.extract_control_options
        runtime_context.runtime_args = self.runtime_args.clone
        runtime_context.add_options("Init Options", init_options)
        runtime_context.add_options("Global Options", Blocks.global_options)
      end
    end

    def to_s
      description = []
      block_name = self.block_name.to_s
      if block_name.include?(" ")
        block_name = ":\"#{block_name}\""
      else
        block_name = ":#{block_name}"
      end
      description << "Block Name: #{block_name}"

      CONTROL_VARIABLES.each do |control_variable, variants|
        if value = send(control_variable)
          description << "#{control_variable}: #{value} [set #{callers[control_variable]}]"
        end
      end

      description << super
      description.join("\n")
    end

    def all_options
      clone.tap do |runtime_context|
        runtime_context.add_options("Init Options", init_options)
        runtime_context.add_options("Global Options", Blocks.global_options)
      end
    end

    def renders_with_proxy?
      render_strategy == :with
    end

    def renders_with_partial?
      render_strategy == :partial
    end

    def renders_with_block?
      render_strategy == :block
    end

    def extract_render_strategy
      add_options("Default Options", delete(:defaults))
      if renders_with_proxy?
        add_proxy_options(self.proxy)
        add_options("Default Options", delete(:defaults))
      end
      if renders_with_block?
        self.render_item = self.block
      elsif renders_with_partial?
        self.render_item = self.partial
      end
      RENDERING_STRATEGIES.each {|rs| delete(rs) }
      self.render_item = runtime_block if render_item.nil?
    end

    def extract_control_options
      CONTROL_VARIABLES.each do |control_variable, variants|
        variant = (Array(variants) + Array(control_variable)).detect {|variant| key?(variant)}
        value = delete(variant)
        callers[control_variable] = callers[variant] if value
        self.send("#{control_variable}=", value)
      end
    end

    def add_proxy_options(proxy_block_name)
      if block_containers.key?(proxy_block_name)
        proxy_block = block_containers[proxy_block_name]
        add_options(proxy_block.name, proxy_block)

        if proxy_block.uses_proxy?
          add_proxy_options(proxy_block.proxy)
        elsif proxy_block.uses_partial?
          self.render_item = proxy_block.partial
        else
          self.render_item = proxy_block.block
        end
      elsif builder.respond_to?(proxy_block_name)
        self.render_item = Proc.new do |*args|
          options = args.extract_options!
          runtime_block = runtime_block || options[:block]
          builder.send(proxy_block_name, *args, options, &runtime_block)
        end
      end
    end

  end
end