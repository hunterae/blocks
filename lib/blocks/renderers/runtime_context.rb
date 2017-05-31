module Blocks
  class RuntimeContext < HashWithRenderStrategy
    CONTROL_VARIABLES = {
      wrap_all: [],
      wrap_each: [:outer_wrapper],
      wrap_with: [:wrap, :wrapper, :inner_wrapper],
      collection: [],
      defaults: [],
      as: []
    }

    attr_accessor(*CONTROL_VARIABLES.keys)
    attr_accessor :block_name,
                  :runtime_block,
                  :builder,
                  :render_item,
                  :runtime_args,
                  :render_options_set,
                  :block_options_set,
                  :proxy_options_set,
                  :parent_options_set,
                  :merged_options_set

    delegate :skip_content, :skip_completely, to: :block_options_set, allow_nil: true

    delegate :block_definitions, :block_defined?, to: :builder

    delegate :runtime_options,
             :standard_options,
             :default_options,
             :options_set,
             prefix: :builder,
             to: :builder

    def initialize(builder, *runtime_args, &runtime_block)
      super(&nil)

      self.builder = builder
      self.runtime_block = runtime_block
      self.proxy_options_set = OptionsSet.new("Proxy Options Set")

      convert_render_options(runtime_args.extract_options!)
      identify_block(runtime_args.shift)

      self.runtime_args = runtime_args
      merge_options_and_identify_render_item
      extract_control_options
    end

    def extend_to_block_definition(block_definition)
      RuntimeContext.new(builder, block_definition, parent_options_set: merged_options_set.clone).tap do |rc|
        rc.runtime_args = self.runtime_args
      end
    end

    # TODO: this method needs to be rewritten to output a proper hash
    def to_s
      description = []
      if block_name
        block_name = self.block_name.to_s
        if block_name.include?(" ")
          block_name = ":\"#{block_name}\""
        else
          block_name = ":#{block_name}"
        end
        description << "Block Name: #{block_name}"
      end

      if render_item.is_a?(String)
        description << "Renders with partial \"#{render_item}\""
      elsif render_item.is_a?(Proc)
        description << "Renders with block defined at #{render_item.source_location}"
      end


      CONTROL_VARIABLES.each do |control_variable, *|
        if value = send(control_variable)
          description << "#{control_variable}: #{value} [#{callers[control_variable]}]"
        end
      end

      description << super
      description.join("\n")
    end

    private

    def convert_render_options(render_options)
      if !render_options.is_a?(HashWithIndifferentAccess)
        render_options = render_options.with_indifferent_access
      end
      self.parent_options_set = render_options.delete(:parent_options_set)
      self.render_options_set = OptionsSet.new(
        "Render Options",
        defaults: render_options.delete(:defaults),
        runtime: render_options
      )
    end

    def identify_block(block_identifier)
      self.block_name, self.block_options_set = if block_identifier.is_a?(OptionsSet)
        [block_identifier.name, block_identifier]
      elsif block_defined?(block_identifier)
        [block_identifier, block_definitions[block_identifier]]
      elsif block_identifier.is_a?(Proc)
        # TODO: figure out how to do this
      else
        [block_identifier, nil]
      end
    end

    def add_proxy_options(proxy_block_name)
      if block_defined?(proxy_block_name)
        proxy_block = block_definitions[proxy_block_name]

        proxy_options_set.add_options(proxy_block)

        render_strategy, render_item = proxy_block.current_render_strategy_and_item

        if render_strategy == RENDER_WITH_PROXY
          add_proxy_options render_item
        else
          render_item
        end

      elsif builder.respond_to?(proxy_block_name)
        Proc.new do |*args|
          options = args.extract_options!
          runtime_block = runtime_block || options[:block]
          builder.send(proxy_block_name, *args, options, &runtime_block)
        end
      end
    end

    def merge_options_and_identify_render_item
      determined_render_item = false
      all_options_sets = [
        render_options_set,
        block_options_set,
        OptionsSet.new("Runtime Block", block: self.runtime_block),
        builder_options_set,
        Blocks.global_options_set,
        parent_options_set
      ].compact

      options_set_with_render_strategy_index = nil
      all_options_sets.
        map(&:render_strategies_and_items).
        transpose.
        detect do |options_for_level|
          options_set_with_render_strategy_index = options_for_level.index(&:present?)
          if options_set_with_render_strategy_index.present?
            self.render_strategy, self.render_item =
              options_for_level[options_set_with_render_strategy_index]
            true
          end
        end

      if self.render_strategy == RENDER_WITH_PROXY
        self.render_item = add_proxy_options render_item
      end

      self.merged_options_set = OptionsSet.new("Parent Options Set")
      [:runtime_options, :standard_options, :default_options].each do |option_level|
        all_options_sets.each_with_index do |options_set, index|
          options_for_level = options_set.send(option_level)
          merged_options_set.send(option_level).add_options(options_for_level)
          add_options options_for_level

          if index == options_set_with_render_strategy_index
            options_for_level = proxy_options_set.send(option_level)
            merged_options_set.send(option_level).add_options(options_for_level)
            add_options options_for_level
          end
        end
      end

      if render_item.blank?
        self.render_item = runtime_block
      end
    end

    def extract_control_options
      CONTROL_VARIABLES.each do |control_variable, synonyms|
        variant = (Array(synonyms) + Array(control_variable)).detect {|variant| key?(variant)}
        value = delete(variant)
        callers[control_variable] = callers[variant] if value
        self.send("#{control_variable}=", value)
      end

      RENDERING_STRATEGIES.each {|rs| delete(rs) }
    end
  end
end