# frozen_string_literal: true

module Blocks
  class RuntimeContext < HashWithRenderStrategy
    CONTROL_VARIABLES = {
      wrap_all: [],
      wrap_each: [:outer_wrapper],
      wrap_with: [:wrap, :wrapper, :inner_wrapper],
      collection: [],
      as: []
    }

    PROTECTED_OPTIONS = RENDERING_STRATEGIES +
      (CONTROL_VARIABLES.keys + CONTROL_VARIABLES.values).flatten.compact

    attr_accessor *CONTROL_VARIABLES.keys,
      :block_name,
      :runtime_block,
      :builder,
      :render_item,
      :runtime_args,
      :merged_block_options,
      :collection_item,
      :collection_item_index,
      :skip_completely,
      :skip_content,
      :hooks

    delegate :block_defined?,
      :block_for,
      :output_buffer,
      :with_output_buffer,
      :capture,
      to: :builder

    def self.build(builder, *runtime_args, &runtime_block)
      new.tap do |runtime_context|
        runtime_context.builder = builder
        runtime_context.runtime_block = runtime_block
        runtime_context.compute(*runtime_args)
      end
    end

    # TODO: change the method signature of this method to def compute(block_identifier, options={}, &runtime_block)
    #  Get rid of most uses of the *
    def compute(*runtime_args)
      render_options = runtime_args.extract_options!
      build_block_context(runtime_args.shift, render_options)
      # TODO: runtime args should be specified as a reserved keyword in the hash
      self.runtime_args = runtime_args
      extract_control_options
    end

    def extend_from_definition(definition, options={}, &runtime_block)
      RuntimeContext.build(
        builder,
        definition,
        # TODO: don't pass runtime args here?
        *runtime_args,
        options.merge(parent_runtime_context: self),
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

    def hooks_or_wrappers_present?
      hooks.present? || wrap_all || wrap_each || wrap_with || collection.present?
    end

    def hooks_for(hook_name)
      hooks[hook_name] if hooks.try(:key?, hook_name)
    end

    def to_hash
      hash = super
      if collection_item_index
        object_name = as || :object
        hash.merge!(object_name => collection_item, current_index: collection_item_index)
      end
      hash
    end

    private

    def add_hooks(block_definition)
      if block_definition.hooks.present?
        self.hooks = Hash.new {|hash, key| hash[key] = [] } if !hooks
        block_definition.hooks.each do |hook_name, hooks|
          self.hooks[hook_name].concat hooks
        end
      end
    end

    def build_block_context(identifier, render_options)
      parent_runtime_context = render_options.delete(:parent_runtime_context)

      self.block_name = identifier if identifier.is_a?(String) || identifier.is_a?(Symbol)

      # Support legacy behavior - i.e. in versions 3.1 and earlier of Blocks,
      #  default render options were given precedence over block-level defaults
      if !Blocks.default_render_options_take_precedence_over_block_defaults
        default_render_options = render_options.delete(:defaults)
      end

      default_options = merge_definition render_options, description: 'Render Options'
      merge_definition identifier, default_options: default_options, merge_default_options: true
      merge_definition default_render_options, description: 'Default Render Options', merge_default_options: true
      merge_definition({ block: runtime_block }, description: 'Runtime Block') if runtime_block
      if parent_runtime_context
        merge_definition parent_runtime_context.merged_block_options, description: "Parent Runtime Context"
        # TODO: setup a configuration to only pull in parent collection item if flag on
        if parent_runtime_context.collection_item_index
          object_name = parent_runtime_context.as || :object
          merge_definition({ 
              object_name => parent_runtime_context.collection_item,
              current_index: parent_runtime_context.collection_item_index
            }, description: "Parent Collection Item")
        end
      end

      # Store the options as a hash  usable in child runtime contexts.
      #  We do this before merging builder and global options as child runtime contexts will themselves merge in builder and global options
      self.merged_block_options = to_hash.except!(*PROTECTED_OPTIONS)

      merge_definition builder.options, description: 'Builder Options', merge_default_options: true
      merge_definition Blocks.global_options, description: 'Global Options', merge_default_options: true
    end

    def merge_definition(definition, description: nil, default_options: [], follow_recursion: false, merge_default_options: false)
      had_render_strategy = render_strategy_item.present?
      follow_recursion ||= !had_render_strategy

      if definition.present?

        if definition.is_a?(Hash)
          default_options << definition.delete(:defaults) if definition.key?(:defaults)
          
          self.block_name = definition.block_to_render if definition.is_a?(HookDefinition)
          reverse_merge! description, definition

          if follow_recursion && renders_with_proxy?
            merge_definition(render_strategy_item, default_options: default_options, follow_recursion: true)
          end

        elsif block_defined?(definition)
          proxy_block = block_for(definition)

          self.skip_content = true if proxy_block.skip_content
          self.skip_completely = true if proxy_block.skip_completely

          add_hooks proxy_block
          reverse_merge! proxy_block

          if proxy_block.default_options
            default_options << proxy_block.default_options
          end

          proxy_render_item = proxy_block.render_strategy_item

          if proxy_block.renders_with_proxy?
            merge_definition proxy_render_item, default_options: default_options, follow_recursion: true if follow_recursion
          elsif follow_recursion
            # reverse_merge! default_options
            # TODO: this should be based on a configuration - whether to use methods
            if proxy_render_item.nil? && builder.respond_to?(definition)
              self.render_item = builder.method(definition)

            else
              self.render_item = proxy_render_item
            end

          end

        elsif builder.respond_to?(definition)
          # TODO: is ||= necessary here?
          self.render_item ||= builder.method(definition)

        end

        # TODO: is this line necessary? Should it be the else clause above
        self.render_item ||= render_strategy_item if !renders_with_proxy?
      end

      if merge_default_options
        default_options.each do |options|
          merge_definition options, merge_default_options: true
        end
      end

      default_options
    end

    def extract_control_options
      CONTROL_VARIABLES.each do |control_variable, synonyms|
        variant = (Array(synonyms) + Array(control_variable)).detect {|variant| key?(variant)}
        value = delete(variant) if variant
        self.send("#{control_variable}=", value)
      end

      except!(*RENDERING_STRATEGIES)
    end
  end
end