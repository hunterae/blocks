module Blocks
  class RuntimeContext < HashWithRenderStrategy
    CONTROL_VARIABLES = {
      wrap_all: [],
      wrap_each: [:outer_wrapper],
      wrap_with: [:wrap, :wrapper, :inner_wrapper],
      collection: [],
      as: []
    }

    attr_accessor(*CONTROL_VARIABLES.keys)
    attr_accessor :block_name,
                  :runtime_block,
                  :builder,
                  :render_item,
                  :runtime_args,
                  :block_options_set,
                  :merged_options_set

    delegate :skip_content, :skip_completely, to: :block_options_set, allow_nil: true

    delegate :block_definitions, :block_defined?, :block_for, to: :builder

    delegate :runtime_options,
             :standard_options,
             :default_options,
             :options_set,
             prefix: :builder,
             to: :builder

    def self.build(builder, *runtime_args, &runtime_block)
      new(builder).tap do |runtime_context|
        runtime_context.runtime_block = runtime_block
        runtime_context.compute(*runtime_args)
      end
    end

    def initialize(builder)
      self.builder = builder
      super
    end

    def compute(*runtime_args)
      render_options = runtime_args.extract_options!.with_indifferent_access

      identify_block(runtime_args.shift)
      if runtime_args.first.is_a?(RuntimeContext)
        parent_runtime_context = runtime_args.shift
      end

      self.runtime_args = runtime_args

      all_options_sets = ordered_option_sets(render_options, parent_runtime_context)
      merge_options_and_identify_render_item(all_options_sets)
      extract_control_options
    end

    def extend_from_definition(block_identifier, options={}, &runtime_block)
      RuntimeContext.build(
        builder,
        block_identifier,
        self,
        *runtime_args,
        options,
        &runtime_block
      )
    end

    # TODO: this method needs to be rewritten to output a proper hash
    # def to_s
    #   description = []
    #   if block_name
    #     block_name = self.block_name.to_s
    #     if block_name.include?(" ")
    #       block_name = ":\"#{block_name}\""
    #     else
    #       block_name = ":#{block_name}"
    #     end
    #     description << "Block Name: #{block_name}"
    #   end
    #
    #   if render_item.is_a?(String)
    #     description << "Renders with partial \"#{render_item}\""
    #   elsif render_item.is_a?(Proc)
    #     description << "Renders with block defined at #{render_item.source_location}"
    #   elsif render_item.is_a?(Method)
    #     description << "Renders with method defined at #{render_item.source_location}"
    #   end
    #
    #
    #   CONTROL_VARIABLES.each do |control_variable, *|
    #     if value = send(control_variable)
    #       # description << "#{control_variable}: #{value} [#{callers[control_variable]}]"
    #     end
    #   end
    #
    #   description << super
    #   description.join("\n")
    # end

    private

    def ordered_option_sets(render_options, parent_runtime_context=nil)
      render_options_set = compute_render_options_set(render_options)

      all_options_sets = [
        render_options_set,
        block_options_set,
        (OptionsSet.new("Runtime Method", with: self.block_name) if self.block_name && builder.respond_to?(block_name)),
        (OptionsSet.new("Runtime Block", block: self.runtime_block) if self.runtime_block),
      ]

      if parent_runtime_context
        all_options_sets << parent_runtime_context.merged_options_set.clone
      else
        all_options_sets << builder_options_set
        all_options_sets << Blocks.global_options_set
      end

      all_options_sets.compact
    end

    def compute_render_options_set(render_options)
      OptionsSet.new(
        "Render Options",
        defaults: render_options.delete(:defaults),
        runtime: render_options
      )
    end

    def identify_block(identifier)
      self.block_name, self.block_options_set = if identifier.is_a?(HookDefinition)
        definition = BlockDefinition.new(identifier.name, runtime: identifier)
        original_definition = block_for(identifier.name)
        if original_definition
          definition.add_options(original_definition)
          definition.skip_content = original_definition.skip_content
          definition.skip_completely = original_definition.skip_completely
        end
        [definition.name, definition]
      elsif identifier.is_a?(OptionsSet)
        [identifier.name, identifier]
      elsif block_defined?(identifier)
        [identifier, block_definitions[identifier]]
      elsif identifier.is_a?(Proc)
        # TODO: figure out how to do this
      else
        [identifier, nil]
      end
    end

    def add_proxy_options(proxy_options_set, proxy_block_name)
      if block_defined?(proxy_block_name)
        proxy_block = block_definitions[proxy_block_name]

        proxy_options_set.add_options(proxy_block)

        render_strategy, render_item = proxy_block.current_render_strategy_and_item

        if render_strategy == RENDER_WITH_PROXY
          add_proxy_options proxy_options_set, render_item
        elsif render_item.nil? && builder.respond_to?(proxy_block_name)
          builder.method(proxy_block_name)
        else
          render_item
        end

      elsif builder.respond_to?(proxy_block_name)
        builder.method(proxy_block_name)
      end
    end

    def merge_options_and_identify_render_item(all_options_sets)
      determined_render_item = false

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
        proxy_options_set = OptionsSet.new("Proxy Options Set")
        self.render_item = add_proxy_options proxy_options_set, render_item
        all_options_sets.insert(options_set_with_render_strategy_index + 1, proxy_options_set)
      end

      self.merged_options_set = OptionsSet.new("Merged Options for #{self.block_name}")
      all_options_sets.each do |options_set|
        merged_options_set.add_options options_set
      end

      add_options merged_options_set.runtime_options
      add_options merged_options_set.standard_options
      add_options merged_options_set.default_options

      if render_item.blank?
        self.render_item = runtime_block
      end
    end

    def extract_control_options
      CONTROL_VARIABLES.each do |control_variable, synonyms|
        variant = (Array(synonyms) + Array(control_variable)).detect {|variant| key?(variant)}
        if variant
          value = delete(variant)
          # callers[control_variable] = callers[variant] if value
        end
        self.send("#{control_variable}=", value)
      end

      RENDERING_STRATEGIES.each {|rs| delete(rs) }
    end
  end
end