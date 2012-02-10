module BuildingBlocks
  TEMPLATE_FOLDER = "blocks"
  USE_PARTIALS = true
  USE_PARTIALS_FOR_BEFORE_AND_AFTER_HOOKS = false

  class Base
    # a pointer to the ActionView that called BuildingBlocks
    attr_accessor :view

    # Hash of block names to BuildingBlocks::Container objects
    attr_accessor :blocks

    # Array of BuildingBlocks::Container objects, storing the order of blocks as they were queued
    attr_accessor :queued_blocks

    # counter, used to give unnamed blocks a unique name
    attr_accessor :anonymous_block_number

    # A Hash of queued_blocks arrays; a new array is started when method_missing is invoked
    attr_accessor :block_groups

    # These are the options that are passed into the initalize method
    attr_accessor :global_options

    # The default folder to look in for global partials
    attr_accessor :templates_folder

    # The variable to use when rendering the partial for the templating feature (by default, "blocks")
    attr_accessor :variable

    # Boolean variable for whether BuildingBlocks should attempt to render blocks as partials if a defined block cannot be found
    attr_accessor :use_partials

    # Boolean variable for whether BuildingBlocks should attempt to render blocks before and after blocks as partials if no before or after blocks exist
    attr_accessor :use_partials_for_before_and_after_hooks

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
    #   whomever calls "blocks.render" on this block.
    # [+block+]
    #   The block that is to be rendered when "blocks.render" is called for this block.
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
    #   whomever calls "blocks.render" on this block.
    # [+block+]
    #   The block that is to be rendered when "blocks.render" is called for this block.
    def replace(name, options={}, &block)
      blocks[name.to_sym] = nil
      self.define_block_container(name, options, &block)
      nil
    end

    # Render a block, first rendering any "before" blocks, then rendering the block itself, then rendering
    # any "after" blocks. BuildingBlocks will make four different attempts to render block:
    #   1) Look for a block that has been defined inline elsewhere, using the blocks.define method:
    #      <% blocks.define :wizard do |options| %>
    #        Inline Block Step#<%= options[:step] %>.
    #      <% end %>
    #
    #      <%= blocks.render :wizard, :step => @step %>
    #   2) Look for a partial within the current controller's view directory:
    #      <%= blocks.render :wizard, :step => @step %>
    #
    #      <!-- In /app/views/pages/_wizard.html.erb (assuming it is the pages controller running): -->
    #      Controller-specific Block Step# <%= step %>.
    #   3) Look for a partial with the global blocks view directory (by default /app/views/blocks/):
    #      <%= blocks.render :wizard, :step => @step %>
    #
    #      <!-- In /app/views/blocks/_wizard.html.erb: -->
    #      Global Block Step#<%= step %>.
    #   4) Render the default implementation for the block if provided to the blocks.render call:
    #      <%= blocks.render :wizard, :step => @step do |options| do %>
    #        Default Implementation Block Step#<%= options %>.
    #      <% end %>
    # Options:
    # [+name+]
    #   The name of the block to render (either a string or a symbol)
    # [+*args+]
    #   Any arguments to pass to the block to be rendered (and also to be passed to any "before" and "after" blocks).
    # [+block+]
    #   The default block to render if no such block block that is to be rendered when "blocks.render" is called for this block.
    def render(name_or_container, *args, &block)
      buffer = ActiveSupport::SafeBuffer.new
      buffer << render_before_blocks(name_or_container, *args)
      buffer << render_block(name_or_container, *args, &block)
      buffer << render_after_blocks(name_or_container, *args)
      buffer
    end
    alias use render

    # Queue a block for later rendering, such as within a template.
    #   <%= BuildingBlocks::Base.new(self).render_template("shared/wizard") do |blocks| %>
    #     <% blocks.queue :step1 %>
    #     <% blocks.queue :step2 do %>
    #       My overridden Step 2 |
    #     <% end %>
    #     <% blocks.queue :step3 %>
    #     <% blocks.queue do %>
    #       | Anonymous Step 4
    #     <% end %>
    #   <% end %>
    #
    #   <!-- In /app/views/shared/wizard -->
    #   <% blocks.define :step1 do %>
    #     Step 1 |
    #   <% end %>
    #
    #   <% blocks.define :step2 do %>
    #     Step 2 |
    #   <% end %>
    #
    #   <% blocks.define :step3 do %>
    #     Step 3
    #   <% end %>
    #
    #   <% blocks.queued_blocks.each do |block| %>
    #     <%= blocks.render block %>
    #   <% end %>
    #
    #   <!-- Will render: Step 1 | My overridden Step 2 | Step 3 | Anonymous Step 4-->
    # Options:
    # [+*args+]
    #   The options to pass in when this block is rendered. These will override any options provided to the actual block
    #   definition. Any or all of these options may be overriden by whoever calls "blocks.render" on this block.
    #   Usually the first of these args will be the name of the block being queued (either a string or a symbol)
    # [+block+]
    #   The optional block definition to render when the queued block is rendered
    def queue(*args, &block)
      self.queued_blocks << self.define_block_container(*args, &block)
      nil
    end

    # Render a partial, treating it as a template, and any code in the block argument will impact how the template renders
    #   <%= BuildingBlocks::Base.new(self).render_template("shared/wizard") do |blocks| %>
    #     <% blocks.queue :step1 %>
    #     <% blocks.queue :step2 do %>
    #       My overridden Step 2 |
    #     <% end %>
    #     <% blocks.queue :step3 %>
    #     <% blocks.queue do %>
    #       | Anonymous Step 4
    #     <% end %>
    #   <% end %>
    #
    #   <!-- In /app/views/shared/wizard -->
    #   <% blocks.define :step1 do %>
    #     Step 1 |
    #   <% end %>
    #
    #   <% blocks.define :step2 do %>
    #     Step 2 |
    #   <% end %>
    #
    #   <% blocks.define :step3 do %>
    #     Step 3
    #   <% end %>
    #
    #   <% blocks.queued_blocks.each do |block| %>
    #     <%= blocks.render block %>
    #   <% end %>
    #
    #   <!-- Will render: Step 1 | My overridden Step 2 | Step 3 | Anonymous Step 4-->
    # Options:
    # [+partial+]
    #   The partial to render as a template
    # [+block+]
    #   An optional block with code that affects how the template renders
    def render_template(partial, &block)
      render_options = global_options.clone
      render_options[self.variable] = self
      render_options[:captured_block] = view.capture(self, &block) if block_given?

      view.render partial, render_options
    end

    # Add a block to render before another block. This before block will be put into an array so that multiple
    #  before blocks may be queued. They will render in the order in which they are declared when the
    #  "blocks#render" method is called. Any options specified to the before block will override any options
    #  specified in the block definition.
    #   <% blocks.define :wizard, :option1 => 1, :option2 => 2 do |options| %>
    #     Step 2 (:option1 => <%= options[option1] %>, :option2 => <%= options[option2] %>)<br />
    #   <% end %>
    #
    #   <% blocks.before :wizard, :option1 => 3 do
    #     Step 0 (:option1 => <%= options[option1] %>, :option2 => <%= options[option2] %>)<br />
    #   <% end %>
    #
    #   <% blocks.before :wizard, :option2 => 4 do
    #     Step 1 (:option1 => <%= options[option1] %>, :option2 => <%= options[option2] %>)<br />
    #   <% end %>
    #
    #   <%= blocks.use :wizard %>
    #
    #   <!-- Will render:
    #     Step 0 (:option1 => 3, :option2 => 2)<br />
    #     Step 1 (:option1 => 1, :option2 => 4)<br />
    #     Step 2 (:option1 => 1, :option2 => 2)<br />
    #   -->
    #
    #   <%= blocks.render :wizard, :step => @step %>
    # Options:
    # [+name+]
    #   The name of the block to render this code before when that block is rendered
    # [+options+]
    #   Any options to specify to the before block when it renders. These will override any options
    #   specified when the block was defined.
    # [+block+]
    #   The block of code to render before another block
    def before(name, options={}, &block)
      self.queue_block_container("before_#{name.to_s}", options, &block)
      nil
    end
    alias prepend before

    # Add a block to render after another block. This after block will be put into an array so that multiple
    #  after blocks may be queued. They will render in the order in which they are declared when the
    #  "blocks#render" method is called. Any options specified to the after block will override any options
    #  specified in the block definition.
    #   <% blocks.define :wizard, :option1 => 1, :option2 => 2 do |options| %>
    #     Step 2 (:option1 => <%= options[option1] %>, :option2 => <%= options[option2] %>)<br />
    #   <% end %>
    #
    #   <% blocks.after :wizard, :option1 => 3 do
    #     Step 3 (:option1 => <%= options[option1] %>, :option2 => <%= options[option2] %>)<br />
    #   <% end %>
    #
    #   <% blocks.after :wizard, :option2 => 4 do
    #     Step 4 (:option1 => <%= options[option1] %>, :option2 => <%= options[option2] %>)<br />
    #   <% end %>
    #
    #   <%= blocks.use :wizard %>
    #
    #   <!-- Will render:
    #     Step 2 (:option1 => 1, :option2 => 2)<br />
    #     Step 3 (:option1 => 3, :option2 => 2)<br />
    #     Step 4 (:option1 => 1, :option2 => 4)<br />
    #   -->
    #
    #   <%= blocks.render :wizard, :step => @step %>
    # Options:
    # [+name+]
    #   The name of the block to render this code after when that block is rendered
    # [+options+]
    #   Any options to specify to the after block when it renders. These will override any options
    #   specified when the block was defined.
    # [+block+]
    #   The block of code to render after another block
    def after(name, options={}, &block)
      self.queue_block_container("after_#{name.to_s}", options, &block)
      nil
    end
    alias append after

    protected

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

      # Capture the contents of the block group (this will only capture block definitions and block renders; it will ignore anything else)
      view.capture(global_options.merge(options), &block) if block_given?

      # restore the original block positions array
      self.queued_blocks = original_queued_blocks
      nil
    end

    def initialize(view, options={})
      self.templates_folder = options[:templates_folder] ? options.delete(:templates_folder) : BuildingBlocks::TEMPLATE_FOLDER
      self.variable = (options[:variable] ? options.delete(:variable) : :blocks).to_sym
      self.view = view
      self.global_options = options
      self.queued_blocks = []
      self.blocks = {}
      self.anonymous_block_number = 0
      self.block_groups = {}
      self.use_partials = options[:use_partials].nil? ? BuildingBlocks::USE_PARTIALS : options.delete(:use_partials)
      self.use_partials_for_before_and_after_hooks =
        options[:use_partials_for_before_and_after_hooks] ? options.delete(:use_partials_for_before_and_after_hooks) : BuildingBlocks::USE_PARTIALS_FOR_BEFORE_AND_AFTER_HOOKS
    end

    # Return a unique name for an anonymously defined block (i.e. a block that has not been given a name)
    def anonymous_block_name
      self.anonymous_block_number += 1
      "block_#{anonymous_block_number}"
    end

    # Render a block, first trying to find a previously defined block with the same name
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
      elsif use_partials
        begin
          begin
            buffer << view.render("#{name.to_s}", global_options.merge(block_options).merge(options))
          rescue ActionView::MissingTemplate
            buffer << view.render("#{self.templates_folder}/#{name.to_s}", global_options.merge(block_options).merge(options))
          end
        rescue ActionView::MissingTemplate
          args.push(global_options.merge(options))
          buffer << view.capture(*(args[0, block.arity]), &block) if block_given?
        end
      else
        args.push(global_options.merge(options))
        buffer << view.capture(*(args[0, block.arity]), &block) if block_given?
      end

      buffer
    end

    # Render all the before blocks for a partial block
    def render_before_blocks(name_or_container, *args)
      render_before_or_after_blocks(name_or_container, "before", *args)
    end

    # Render all the after blocks for a partial block
    def render_after_blocks(name_or_container, *args)
      render_before_or_after_blocks(name_or_container, "after", *args)
    end

    # Utility method to render either the before or after blocks for a partial block
    def render_before_or_after_blocks(name_or_container, before_or_after, *args)
      options = args.extract_options!

      block_options = {}
      if (name_or_container.is_a?(BuildingBlocks::Container))
        name = name_or_container.name.to_sym
        block_options = name_or_container.options
      else
        name = name_or_container.to_sym
        block_options = blocks[name].options if blocks[name]
      end

      before_name = "#{before_or_after}_#{name.to_s}".to_sym
      buffer = ActiveSupport::SafeBuffer.new

      if blocks[before_name].present?
        blocks[before_name].each do |block_container|
          args_clone = args.clone
          args_clone.push(global_options.merge(block_options).merge(block_container.options).merge(options))
          buffer << view.capture(*(args_clone[0, block_container.block.arity]), &block_container.block)
        end
      elsif use_partials && use_partials_for_before_and_after_hooks
        begin
          begin
            buffer << view.render("#{before_or_after}_#{name.to_s}", global_options.merge(block_options).merge(options))
          rescue ActionView::MissingTemplate
            buffer << view.render("#{self.templates_folder}/#{before_or_after}_#{name.to_s}", global_options.merge(block_options).merge(options))
          end
        rescue ActionView::MissingTemplate
        end
      end

      buffer
    end

    # Build a BuildingBlocks::Container object given the passed in arguments
    def build_block_container(*args, &block)
      options = args.extract_options!
      name = args.first ? args.shift : self.anonymous_block_name
      block_container = BuildingBlocks::Container.new
      block_container.name = name.to_sym
      block_container.options = options
      block_container.block = block
      block_container
    end

    # Build a BuildingBlocks::Container object and add it to an array of containers matching it's block name
    #  (used only for queuing a collection of before and after blocks for a particular block name)
    def queue_block_container(*args, &block)
      block_container = self.build_block_container(*args, &block)
      if blocks[block_container.name].nil?
        blocks[block_container.name] = [block_container]
      else
        blocks[block_container.name] << block_container
      end
    end

    # Build a BuildingBlocks::Container object and add it to the global hash of blocks if a block by the same
    #  name is not already defined
    def define_block_container(*args, &block)
      block_container = self.build_block_container(*args, &block)
      blocks[block_container.name] = block_container if blocks[block_container.name].nil? && block_given?
      block_container
    end
  end
end
