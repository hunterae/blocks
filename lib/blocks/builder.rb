require 'call_with_params'

module Blocks
  class Builder
    include CallWithParams

    # Whether this instance is a child of another instance
    attr_accessor :parent_manager

    attr_accessor :init_options

    # counter, used to give unnamed blocks a unique name
    attr_accessor :anonymous_block_number

    attr_accessor :block_containers

    attr_accessor :view

    attr_accessor :renderer

    attr_accessor :skipped_blocks

    def initialize(view, init_options={}, parent_manager=nil)
      self.view = view
      self.init_options = init_options.with_indifferent_access
      self.parent_manager = parent_manager
      self.anonymous_block_number = 0
      self.block_containers =
        HashWithIndifferentAccess.new { |hash, key| hash[key] = BlockContainer.new }
      self.skipped_blocks = HashWithIndifferentAccess.new

      define :block_wrapper, wrapper_html: { }, wrapper_tag: :div do |content_block, options|
        view.content_tag options[:wrapper_tag], options[:wrapper_html], &content_block
      end
    end

    def renderer
      @renderer ||= Renderer.new(self)
    end

    delegate :render, :render_with_overrides, to: :renderer

    # Checks if a particular block has been defined within the current block scope.
    #   <%= blocks.defined? :some_block_name %>
    # Options:
    # [+name+]
    #   The name of the block to check
    def block_defined?(name)
      name && block_containers.key?(name)
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
    def define(name, options={}, &block)
      collection = options.delete(:collection)

      if collection
        collection.each do |object|
          define(call_with_params(name, object, options), options, &block)
        end
      else
        define_block_container(name, options, &block)
      end
    end

    def deferred_render(name, options={}, &block)
      define(name, options, &block)
      "PLACEHOLDER_FOR_#{name}"
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
      define_block_container(name, options, &block)
    end

    def skip(name, skip_all_hooks=false)
      skipped_blocks[name] = { skip_all_hooks: skip_all_hooks }
    end

    BlockContainer::HOOKS_AND_QUEUEING_TECHNIQUE.each do |hook, *|
      define_method(hook) do |name, *args, &block|
        block_container = block_containers[name]
        block_container.send(hook, name, *args, &block)
      end
    end

    protected

    # Return a unique name for an anonymously defined block (i.e. a block that has not been given a name)
    def anonymous_block_name
      self.anonymous_block_number += 1
      "block_#{anonymous_block_number}"
    end

    # Build a BlockContainer object and add it to the global hash of block_containers
    #  if a block by the same name is not already defined
    def define_block_container(*args, &block)
      if args.first
        name = args.shift
        anonymous = false
      else
        name = anonymous_block_name
        anonymous = true
      end

      block_containers[name].tap do |block_container|
        block_container.add_options args.extract_options!
        block_container.block = block if block_given? && block_container.block.nil?
        block_container.anonymous = anonymous
      end
    end

  end
end
