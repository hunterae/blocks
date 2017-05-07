require 'call_with_params'

module Blocks
  class Builder
    include CallWithParams

    attr_accessor :view
    attr_accessor :block_definitions
    attr_accessor :options_set
    # counter, used to give unnamed blocks a unique name
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

    def initialize(view, init_options={})
      self.view = view
      self.anonymous_block_number = 0
      self.block_definitions = HashWithIndifferentAccess.new
      block_definitions.default_proc = Proc.new do |hash, key|
        hash[key] = BlockDefinition.new(key)
      end
      self.options_set = OptionsSet.new("Builder Options")

      options_set.add_options(init_options)
      options_set.add_options(Blocks.global_options)

      define_helper_blocks
    end

    def renderer
      @renderer ||= Blocks.renderer_class.new(self)
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
        anonymous = false
      else
        name = anonymous_block_name
        anonymous = true
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

    def skipped?(name)
      block_definitions[name].skip_content
    end

    HookDefinition::HOOKS.each do |hook|
      define_method(hook) do |name, options={}, &block|
        block_definitions[name].send(hook, options, &block)
      end
    end

    def concatenating_merge(options, options2, *args)
      options = call_each_hash_value_with_params(options, *args)
      options2 = call_each_hash_value_with_params(options2, *args)

      options.to_h.symbolize_keys.merge(options2.to_h.symbolize_keys) {|key, v1, v2| "#{v1} #{v2}" }
    end

    protected

    # Return a unique name for an anonymously defined block (i.e. a block that has not been given a name)
    def anonymous_block_name
      self.anonymous_block_number += 1
      "block_#{anonymous_block_number}"
    end

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
