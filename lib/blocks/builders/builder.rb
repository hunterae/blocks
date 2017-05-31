require 'call_with_params'

module Blocks
  class Builder
    include CallWithParams

    # A pointer to the view context
    attr_accessor :view

    # A HashWithIndifferentAccess of block names to BlockDefinition mappings
    attr_accessor :block_definitions

    # Options provided during initialization of builder
    attr_accessor :options_set

    delegate :content_tag, to: :view

    delegate :render,
             :render_with_overrides,
             :deferred_render,
             to: :renderer

    delegate :runtime_options,
             :standard_options,
             :default_options,
             to: :options_set

    CONTENT_TAG_WRAPPER_BLOCK = :content_tag_wrapper

    def initialize(view, options={})
      self.view = view
      self.block_definitions = HashWithIndifferentAccess.new do |hash, key|
        hash[key] = BlockDefinition.new(key); hash[key]
      end
      self.options_set = OptionsSet.new("Builder Options", options)
      define_helper_blocks
    end

    def renderer
      @renderer ||= Blocks.renderer_class.new(self)
    end

    def block_for(block_name)
      block_definitions[block_name] if block_defined?(block_name)
    end

    def block_defined?(block_name)
      block_definitions.key?(block_name)
    end

    def define_each(collection, block_name_proc, *args, &block)
      collection.map do |object|
        define(call_with_params(block_name_proc, object, *args), object, *args, &block)
      end
    end

    # Define a block, unless a block by the same name is already defined.
    #   <%= blocks.define :some_block_name, :parameter1 => "1", :parameter2 => "2" do |options| %>
    #     <%= options[:parameter1] %> and <%= options[:parameter2] %>
    #   <% end %>
    #
    # Options:
    # [+name+]
    #   The name of the block being defined (either a string or a symbol)
    # [+options+]
    #   The default options for the block definition. Any or all of these options may be overridden by
    #   whomever calls "blocks.render" on this block.
    # [+block+]
    #   The block that is to be rendered when "blocks.render" is called for this block.
    def define(*args, &block)
      options = args.extract_options!

      if args.first
        name = args.shift
        block_definitions[name].tap do |block_definition|
          block_definition.add_options options, &block
        end
      else
        BlockDefinition.new(options, &block)
      end
    end

    # Define a block, replacing an existing block by the same name if it is already defined.
    #   <%= blocks.define :some_block_name, :parameter1 => "1", :parameter2 => "2" do |options| %>
    #     <%= options[:parameter1] %> and <%= options[:parameter2] %>
    #   <% end %>
    #
    #   <%= blocks.replace :some_block_name, :parameter3 => "3", :parameter4 => "4" do |options| %>
    #     <%= options[:parameter3] %> and <%= options[:parameter4] %>
    #   <% end %>
    # Options:
    # [+name+]
    #   The name of the block being defined (either a string or a symbol)
    # [+options+]
    #   The default options for the block definition. Any or all of these options may be overridden by
    #   whomever calls "blocks.render" on this block.
    # [+block+]
    #   The block that is to be rendered when "blocks.render" is called for this block.
    def replace(name, options={}, &block)
      block_definitions.delete(name)
      define(name, options, &block)
    end

    def skip(name, completely=false)
      block_definitions[name].skip(completely)
    end

    def skip_completely(name)
      skip(name, true)
    end

    HookDefinition::HOOKS.each do |hook|
      define_method(hook) do |name, options={}, &block|
        block_definitions[name].send(hook, options, &block)
      end
    end

    # TODO: move this logic elsewhere
    def concatenating_merge(options, options2, *args)
      options = call_each_hash_value_with_params(options, *args) || {}
      options2 = call_each_hash_value_with_params(options2, *args) || {}


      options.symbolize_keys.merge(options2.symbolize_keys) do |key, v1, v2|
        if v1.is_a?(String) && v2.is_a?(String)
          "#{v1} #{v2}"
        else
          v2
        end
      end
    end

    protected

    # TODO: move this logic elsewhere
    def define_helper_blocks
      define CONTENT_TAG_WRAPPER_BLOCK, defaults: { wrapper_tag: :div } do |content_block, *args|
        options = args.extract_options!
        wrapper_options = if options[:wrapper_html_option]
          if options[:wrapper_html_option].is_a?(Array)
            wrapper_attribute = nil
            options[:wrapper_html_option].each do |attribute|
              if options[attribute].present?
                wrapper_attribute = attribute
                break
              end
            end
            options[wrapper_attribute]
          else
            options[options[:wrapper_html_option]]
          end
        end
        content_tag options[:wrapper_tag],
          concatenating_merge(options[:wrapper_html], wrapper_options, *args, options),
          &content_block
      end
    end
  end
end
