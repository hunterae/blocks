require 'call_with_params'

module Blocks
  class Builder
    include CallWithParams

    attr_accessor :init_options

    # counter, used to give unnamed blocks a unique name
    attr_accessor :anonymous_block_number

    attr_accessor :block_containers

    attr_accessor :view

    attr_accessor :default_renderer

    delegate :render, :render_with_overrides, to: :default_renderer

    def initialize(view, init_options={})
      self.view = view
      self.init_options = init_options.with_indifferent_access
      self.anonymous_block_number = 0
      self.block_containers =
        HashWithIndifferentAccess.new { |hash, key| hash[key] = BlockContainer.new }
    end

    def default_renderer
      @default_renderer ||= Blocks.renderer_class.new(self)
    end

    AbstractRenderer::RENDERERS.each do |klass|
      name = klass.to_s.demodulize.underscore

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{name}
          @#{name} ||= #{klass}.new(self)
        end
      RUBY
    end

    def block_defined?(block_name)
      block_name && block_containers.key?(block_name)
    end

    # Define a block, unless a block by the same name is already defined.
    #   <%= blocks.define :some_block_name, :parameter1 => "1", :parameter2 => "2" do |options| %>
    #     <%= options[:parameter1] %> and <%= options[:parameter2] %>
    #   <% end %>
    #
    # Options:
    # [+name+]
    #   The name of the block being defined (either a string or a symbol or a Proc)
    # [+options+]
    #   The default options for the block definition. Any or all of these options may be overridden by
    #   whomever calls "blocks.render" on this block. If :collection => some_array,
    #   Blocks will assume that the first argument is a Proc and define a block for each object in the
    #   collection
    # [+block+]
    #   The block that is to be rendered when "blocks.render" is called for this block.
    def define(*args, &block)
      options = args.extract_options!

      collection = options.delete(:collection)
      if collection
        collection.map do |object|
          define(call_with_params(args.first, object, options), options, &block)
        end

      else
        if args.first
          name = args.shift
          anonymous = false
        else
          name = anonymous_block_name
          anonymous = true
        end

        block_containers[name].tap do |block_container|
          block_container.add_options options
          block_container.name = name
          block_container.block = block if block_given? && block_container.block.nil?
          block_container.anonymous = anonymous
        end
      end
    end

    def deferred_render(*args, &block)
      block_container = define(*args, &block)
      "PLACEHOLDER_FOR_#{block_container.name} "
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
      blocks[name] = nil
      define(name, options, &block)
    end

    def skip(name, completely=false)
      block_containers[name].skip(completely)
    end

    def skip_completely(name)
      skip(name, true)
    end

    BlockContainer::HOOKS.each do |hook|
      define_method(hook) do |name, options={}, &block|
        block_containers[name].send(hook, options, &block)
      end
    end

    protected

    # Return a unique name for an anonymously defined block (i.e. a block that has not been given a name)
    def anonymous_block_name
      self.anonymous_block_number += 1
      "block_#{anonymous_block_number}"
    end
  end
end
