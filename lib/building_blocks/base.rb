module BuildingBlocks
  BUILDING_BLOCKS_TEMPLATE_FOLDER = "blocks"

  class Base
    attr_accessor :view

    attr_accessor :blocks

    attr_accessor :block

    # Array of BuildingBlocks::Container objects, storing the order of blocks as they were queued
    attr_accessor :queued_blocks

    # counter, used to give unnamed blocks a unique name
    attr_accessor :anonymous_block_number

    attr_accessor :block_groups

    # These are the options that are passed into the initalize method
    attr_accessor :global_options

    # Checks if a particular block has been defined within the current block scope.
    #   <%= blocks.defined? :some_block_name %>
    # Options:
    # [+name+]
    #   The name of the block to check
    def defined?(name)
      !blocks[name.to_sym].nil?
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
    #   The default options for the block definition. Any or all of these options may be overrideen by
    #   whomever calls "blocks.use" on this block.
    # [+block+]
    #   The block that is to be rendered when "blocks.use" is called for this block.
    def define(name, options={}, &block)
      self.define_block_container(name, options, &block)
      nil
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
    #   The default options for the block definition. Any or all of these options may be overrideen by
    #   whomever calls "blocks.use" on this block.
    # [+block+]
    #   The block that is to be rendered when "blocks.use" is called for this block.
    def replace(name, options={}, &block)
      blocks[name.to_sym] = nil
      self.define_block_container(name, options, &block)
      nil
    end

    def use(*args, &block)
      name_or_container = args.first ? args.shift : self.anonymous_block_name
      buffer = ActiveSupport::SafeBuffer.new
      buffer << render_before_blocks(name_or_container, *args)
      buffer << render_block(name_or_container, *args, &block)
      buffer << render_after_blocks(name_or_container, *args)
      buffer
    end

    def queue(*args, &block)
      self.queued_blocks << self.define_block_container(*args, &block)
      nil
    end

    def render
      raise "Must specify :template parameter in order to render" unless global_options[:template]

      render_options = global_options.clone
      render_options[render_options[:variable] ? render_options[:variable].to_sym : :blocks] = self
      render_options[:captured_block] = view.capture(self, &self.block) if self.block

      view.render global_options[:template], render_options
    end

    def before(name, options={}, &block)
      self.queue_block_container("before_#{name.to_s}", options, &block)
      nil
    end
    alias prepend before

    def after(name, options={}, &block)
      self.queue_block_container("after_#{name.to_s}", options, &block)
      nil
    end
    alias append after

    # If a method is missing, we'll assume the user is starting a new block group by that missing method name
    def method_missing(m, *args, &block)
      options = args.extract_options!

      # If the specified block group has already been defined, it is simply returned here for iteration.
      #  It will consist of all the blocks used in this block group that have yet to be rendered,
      #   as the call for their use occurred before the template was rendered (where their definitions likely occurred)
      return self.block_groups[m] unless self.block_groups[m].nil?

      # Allows for nested block groups, store the current block positions array and start a new one
      original_queued_blocks = self.queued_blocks
      self.queued_blocks = []
      self.block_groups[m] = self.queued_blocks

      # Capture the contents of the block group (this will only capture block definitions and block uses)
      view.capture(global_options.merge(options), &block) if block_given?

      # restore the original block positions array
      self.queued_blocks = original_queued_blocks
      nil
    end

    protected

    def initialize(view, options={}, &block)
      options[:templates_folder] = BuildingBlocks::BUILDING_BLOCKS_TEMPLATE_FOLDER if options[:templates_folder].nil?

      self.view = view
      self.global_options = options
      self.block = block
      self.queued_blocks = []
      self.blocks = {}
      self.anonymous_block_number = 0
      self.block_groups = {}
    end

    def anonymous_block_name
      self.anonymous_block_number += 1
      "block_#{anonymous_block_number}"
    end

    def render_block(name_or_container, *args, &block)
      options = args.extract_options!

      buffer = ActiveSupport::SafeBuffer.new

      block_options = {}
      if (name_or_container.is_a?(BuildingBlocks::Container))
        name = name_or_container.name.to_sym
        block_options = name_or_container.options
      else
        name = name_or_container.to_sym
      end

      if blocks[name]
        block_container = blocks[name]
        args.push(global_options.merge(block_container.options).merge(block_options).merge(options))
        buffer << view.capture(*(args[0, block_container.block.arity]), &block_container.block)
      else
        begin
          begin
            buffer << view.render("#{name.to_s}", global_options.merge(block_options).merge(options))
          rescue ActionView::MissingTemplate
            buffer << view.render("#{self.global_options[:templates_folder]}/#{name.to_s}", global_options.merge(block_options).merge(options))
          end
        rescue ActionView::MissingTemplate
          args.push(global_options.merge(options))
          buffer << view.capture(*(args[0, block.arity]), &block) if block_given?
        end
      end

      buffer
    end

    def render_before_blocks(name_or_container, *args)
      options = args.extract_options!

      block_options = {}
      if (name_or_container.is_a?(BuildingBlocks::Container))
        name = name_or_container.name.to_sym
        block_options = name_or_container.options
      else
        name = name_or_container.to_sym
        block_options = blocks[name].options if blocks[name]
      end

      before_name = "before_#{name.to_s}".to_sym
      buffer = ActiveSupport::SafeBuffer.new

      if blocks[before_name].present?
        blocks[before_name].each do |block_container|
          args_clone = args.clone
          args_clone.push(global_options.merge(block_options).merge(block_container.options).merge(options))
          buffer << view.capture(*(args_clone[0, block_container.block.arity]), &block_container.block)
        end
      else
        begin
          begin
            buffer << view.render("before_#{name.to_s}", global_options.merge(block_options).merge(options))
          rescue ActionView::MissingTemplate
            buffer << view.render("#{self.global_options[:templates_folder]}/before_#{name.to_s}", global_options.merge(block_options).merge(options))
          end
        rescue ActionView::MissingTemplate
        end
      end

      buffer
    end

    def render_after_blocks(name_or_container, *args)
      options = args.extract_options!

      block_options = {}
      if (name_or_container.is_a?(BuildingBlocks::Container))
        name = name_or_container.name.to_sym
        block_options = name_or_container.options
      else
        name = name_or_container.to_sym
        block_options = blocks[name].options if blocks[name]
      end

      after_name = "after_#{name.to_s}".to_sym
      buffer = ActiveSupport::SafeBuffer.new

      if blocks[after_name].present?
        blocks[after_name].each do |block_container|
          args_clone = args.clone
          args_clone.push(global_options.merge(block_options).merge(block_container.options).merge(options))
          buffer << view.capture(*(args_clone[0, block_container.block.arity]), &block_container.block)
        end
      else
        begin
          begin
            buffer << view.render("after_#{name.to_s}", global_options.merge(block_options).merge(options))
          rescue ActionView::MissingTemplate
            buffer << view.render("#{self.global_options[:templates_folder]}/after_#{name.to_s}", global_options.merge(block_options).merge(options))
          end
        rescue ActionView::MissingTemplate
        end
      end

      buffer
    end

    def build_block_container(*args, &block)
      options = args.extract_options!
      name = args.first ? args.shift : self.anonymous_block_name
      block_container = BuildingBlocks::Container.new
      block_container.name = name.to_sym
      block_container.options = options
      block_container.block = block
      block_container
    end

    def queue_block_container(*args, &block)
      block_container = self.build_block_container(*args, &block)
      if blocks[block_container.name].nil?
        blocks[block_container.name] = [block_container]
      else
        blocks[block_container.name] << block_container
      end
    end

    def define_block_container(*args, &block)
      block_container = self.build_block_container(*args, &block)
      blocks[block_container.name] = block_container if blocks[block_container.name].nil? && block_given?
      block_container
    end
  end
end
