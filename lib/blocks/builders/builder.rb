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

    attr_accessor :anonymous_block_number

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
      if defined?(::Haml) && !view.instance_variables.include?(:@haml_buffer)
        class << view
          include Haml::Helpers
        end
        view.init_haml_helpers
      end
      self.view = view
      self.block_definitions = HashWithIndifferentAccess.new do |hash, key|
        hash[key] = BlockDefinition.new(key); hash[key]
      end
      self.anonymous_block_number = 0
      self.options_set = OptionsSet.new("Builder Options", options)
      define_helper_blocks
    end

    def renderer
      @renderer ||= Blocks.renderer_class.new(self)
    end

    def block_for(block_name)
      block_definitions[block_name] if block_defined?(block_name)
    end

    def hooks_for(block_name, hook_name)
      block_for(block_name).try(:hooks_for, hook_name) || []
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

      name, anonymous = if args.first
        [args.shift, false]
      else
        self.anonymous_block_number += 1
        ["anonymous_block_#{anonymous_block_number}", true]
      end

      block_definitions[name].tap do |block_definition|
        block_definition.add_options options, &block
        block_definition.anonymous = anonymous
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

    # Blocks::Builder.content_tag extends ActionView's content_tag method
    #  by allowing itself to be used as a wrapper, hook, or called directly,
    #  while also not requiring the content tag name (defaults to :div).
    def content_tag(*args, &block)
      options = args.extract_options!
      escape = options.key?(:escape) ? options.delete(:escape) : true

      if options.is_a?(Blocks::RuntimeContext)
        if options[:wrapper_type]
          wrapper_prefix = options[:wrapper_type]

          html_option = options["#{wrapper_prefix}_html_option"]
          wrapper_html = if html_option.is_a?(Array)
            html_option.map do |html_attribute|
              options[html_attribute]
            end.compact.first

          elsif html_option.present?
            options[html_option]
          end || options["#{wrapper_prefix}_html"]

          wrapper_tag = options["#{wrapper_prefix}_tag"]

        else
          wrapper_tag = options[:tag]
        end

        wrapper_html ||= options["html"] || {}

      else
        wrapper_tag = options.delete(:tag)
        wrapper_html = options.to_hash
      end

      if !wrapper_tag
        first_arg = args.first
        wrapper_tag = if first_arg.is_a?(String) || first_arg.is_a?(Symbol)
          args.shift
        else
          :div
        end
      end

      content_tag_args = [wrapper_tag]
      content_tag_args << args.shift if !block_given?
      content_tag_args << wrapper_html
      content_tag_args << escape

      view.content_tag *content_tag_args, &block
    end

    protected

    # DEPRECATED
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
        view.content_tag options[:wrapper_tag],
          concatenating_merge(options[:wrapper_html], wrapper_options, *args, options),
          &content_block
      end
    end
  end
end
