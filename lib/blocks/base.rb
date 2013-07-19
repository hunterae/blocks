module Blocks
  class Base
    # a pointer to the ActionView that called Blocks
    attr_accessor :view

    # Hash of block names to Blocks::Container objects
    attr_accessor :blocks

    # Array of Blocks::Container objects, storing the order of blocks as they were queued
    attr_accessor :queued_blocks

    # counter, used to give unnamed blocks a unique name
    attr_accessor :anonymous_block_number

    # A Hash of queued_blocks arrays; a new array is started when method_missing is invoked
    attr_accessor :block_groups

    # These are the options that are passed into the initalize method
    attr_accessor :global_options

    # The default folder to look in for global partials
    attr_accessor :template_folder

    # The variable to use when rendering the partial for the templating feature (by default, "blocks")
    attr_accessor :variable

    # Boolean variable for whether Blocks should attempt to render blocks as partials if a defined block cannot be found
    attr_accessor :use_partials

    # Boolean variable for whether Blocks should render before and after blocks inside or outside of a collections' elements' surrounding tags
    attr_accessor :surrounding_tag_surrounds_before_and_after_blocks

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
      collection = options.delete(:collection)

      if collection
        collection.each do |object|
          define(evaluated_proc(name, object, options), options, &block)
        end
      else
        self.define_block_container(name, options, &block)
      end

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
    # any "after" blocks. Additionally, a collection may also be passed in, and Blocks will render
    # an the block, along with corresponding before and after blocks for each element of the collection.
    # Blocks will make either two or four different attempts to render the block, depending on how use_partials
    # is globally set, or an option is passed in to the render call to either use partials or skip partials:
    #   1) Look for a block that has been defined inline elsewhere, using the blocks.define method:
    #      <% blocks.define :wizard do |options| %>
    #        Inline Block Step#<%= options[:step] %>.
    #      <% end %>
    #
    #      <%= blocks.render :wizard, :step => @step %>
    #   2) [IF use_partials is globally set to true or passed in as a runtime option,
    #       and skip_partials is not passed in as a runtime option]
    #      Look for a partial within the current controller's view directory:
    #      <%= blocks.render :wizard, :step => @step %>
    #
    #      <!-- In /app/views/pages/_wizard.html.erb (assuming it is the pages controller running): -->
    #      Controller-specific Block Step# <%= step %>.
    #   3) [IF use_partials is globally set to true or passed in as a runtime option,
    #       and skip_partials is not passed in as a runtime option]
    #      Look for a partial with the global blocks view directory (by default /app/views/blocks/):
    #      <%= blocks.render :wizard, :step => @step %>
    #
    #      <!-- In /app/views/blocks/_wizard.html.erb: -->
    #      Global Block Step#<%= step %>.
    #   4) Render the default implementation for the block if provided to the blocks.render call:
    #      <%= blocks.render :wizard, :step => @step do |options| do %>
    #        Default Implementation Block Step#<%= options %>.
    #      <% end %>
    # Options:
    # [+name_or_container+]
    #   The name of the block to render (either a string or a symbol)
    # [+*args+]
    #   Any arguments to pass to the block to be rendered (and also to be passed to any "before" and "after" blocks).
    #   The last argument in the list can be a hash and can include the following special options:
    #     [:collection]
    #       The collection of elements to render blocks for
    #     [:as]
    #       The variable name to assign the current element in the collection being rendered over
    #     [:surrounding_tag]
    #       The content tag to render around a block, which might be particularly useful when rendering a collection of blocks,
    #       such as for a list or table
    #     [:surrounding_tag_html]
    #       The attributes to be applied to the HTML content tag, such as styling or special properties. Please note, any Procs passed
    #       in will automatically be evaluated (For example: :class => lambda { cycle("even", "odd") })
    #     [:use_partials]
    #       Overrides the globally defined use_partials and tells Blocks to render partials in trying to render a block
    #     [:skip_partials]
    #       Overrides the globally defined use_partials and tells Blocks to not render any partials in trying to render a block
    # [+block+]
    #   The default block to render if no such block block that is to be rendered when "blocks.render" is called for this block.
    def render(name_or_container, *args, &block)
      options = args.extract_options!
      collection = options.delete(:collection)

      buffer = ActiveSupport::SafeBuffer.new

      if collection
        as = options.delete(:as)

        collection.each do |object|
          cloned_args = args.clone
          cloned_args.unshift(object)
          cloned_options = options.clone
          cloned_options = cloned_options.merge(object.options) if object.is_a?(Blocks::Container)
          cloned_args.push(cloned_options)

          block_name = evaluated_proc(name_or_container, *cloned_args)
          as_name = (as.presence || block_name).to_sym
          cloned_options[as_name] = object

          buffer << render(block_name, *cloned_args, &block)
        end
      else
        surrounding_tag = options.delete(:surrounding_tag)
        surrounding_tag_html = options.delete(:surrounding_tag_html)

        args.push(options)

        if surrounding_tag_surrounds_before_and_after_blocks
          buffer << content_tag(surrounding_tag, surrounding_tag_html, *args) do
            temp_buffer = ActiveSupport::SafeBuffer.new
            temp_buffer << render_before_blocks(name_or_container, *args)
            temp_buffer << render_block_with_around_blocks(name_or_container, *args, &block)
            temp_buffer << render_after_blocks(name_or_container, *args)
          end
        else
          buffer << render_before_blocks(name_or_container, *args)
          buffer << content_tag(surrounding_tag, surrounding_tag_html, *args) do
            render_block_with_around_blocks(name_or_container, *args, &block)
          end
          buffer << render_after_blocks(name_or_container, *args)
        end
      end

      buffer
    end
    alias use render

    # Render a block, first rendering any "before" blocks, then rendering the block itself, then rendering
    # any "after" blocks. Additionally, a collection may also be passed in, and Blocks will render
    # an the block, along with corresponding before and after blocks for each element of the collection.
    # Blocks will make two different attempts to render block:
    #   1) Look for a block that has been defined inline elsewhere, using the blocks.define method:
    #      <% blocks.define :wizard do |options| %>
    #        Inline Block Step#<%= options[:step] %>.
    #      <% end %>
    #
    #      <%= blocks.render :wizard, :step => @step %>
    #   2) Render the default implementation for the block if provided to the blocks.render call:
    #      <%= blocks.render :wizard, :step => @step do |options| do %>
    #        Default Implementation Block Step#<%= options %>.
    #      <% end %>
    # Options:
    # [+name_or_container+]
    #   The name of the block to render (either a string or a symbol)
    # [+*args+]
    #   Any arguments to pass to the block to be rendered (and also to be passed to any "before" and "after" blocks).
    #   The last argument in the list can be a hash and can include the following special options:
    #     [:collection]
    #       The collection of elements to render blocks for
    #     [:as]
    #       The variable name to assign the current element in the collection being rendered over
    #     [:surrounding_tag]
    #       The content tag to render around a block, which might be particularly useful when rendering a collection of blocks,
    #       such as for a list or table
    #     [:surrounding_tag_html]
    #       The attributes to be applied to the HTML content tag, such as styling or special properties. Please note, any Procs passed
    #       in will automatically be evaluated (For example: :class => lambda { cycle("even", "odd") })
    # [+block+]
    #   The default block to render if no such block block that is to be rendered when "blocks.render" is called for this block.
    def render_without_partials(name_or_container, *args, &block)
      options = args.extract_options!
      options[:skip_partials] = true
      args.push(options)
      render(name_or_container, *args, &block)
    end

    # Render a block, first rendering any "before" blocks, then rendering the block itself, then rendering
    # any "after" blocks. Additionally, a collection may also be passed in, and Blocks will render
    # an the block, along with corresponding before and after blocks for each element of the collection.
    # Blocks will make four different attempts to render block:
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
    # [+name_or_container+]
    #   The name of the block to render (either a string or a symbol)
    # [+*args+]
    #   Any arguments to pass to the block to be rendered (and also to be passed to any "before" and "after" blocks).
    #   The last argument in the list can be a hash and can include the following special options:
    #     [:collection]
    #       The collection of elements to render blocks for
    #     [:as]
    #       The variable name to assign the current element in the collection being rendered over
    #     [:surrounding_tag]
    #       The content tag to render around a block, which might be particularly useful when rendering a collection of blocks,
    #       such as for a list or table
    #     [:surrounding_tag_html]
    #       The attributes to be applied to the HTML content tag, such as styling or special properties. Please note, any Procs passed
    #       in will automatically be evaluated (For example: :class => lambda { cycle("even", "odd") })
    # [+block+]
    #   The default block to render if no such block block that is to be rendered when "blocks.render" is called for this block.
    def render_with_partials(name_or_container, *args, &block)
      options = args.extract_options!
      options[:use_partials] = true
      args.push(options)
      render(name_or_container, *args, &block)
    end

    # Queue a block for later rendering, such as within a template.
    #   <%= Blocks::Base.new(self).render_template("shared/wizard") do |blocks| %>
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
    #   <%= Blocks::Base.new(self).render_template("shared/wizard") do |blocks| %>
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
    #   <%= blocks.render :wizard %>
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
    #   <%= blocks.render :wizard %>
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
    alias for after

    # Add a block to render around another block. This around block will be put into an array so that multiple
    #  around blocks may be queued. They will render in the order in which they are declared when the
    #  "blocks#render" method is called, with the last declared around block being rendered as the outer-most code, and
    #  the first declared around block rendered as the inner-most code. Any options specified to the after block will override any options
    #  specified in the block definition. The user of an around block must declare a block with at least one parameter and
    #  should invoke the #call method on that argument.
    #
    #   <% blocks.define :my_block do %>
    #     test
    #   <% end %>
    #
    #   <% blocks.around :my_block do |content_block| %>
    #     <h1>
    #       <%= content_block.call %>
    #     </h1>
    #   <% end %>
    #
    #   <% blocks.around :my_block do |content_block| %>
    #     <span style="color:red">
    #       <%= content_block.call %>
    #     </span>
    #   <% end %>
    #
    #   <%= blocks.render :my_block %>
    #
    #   <!-- Will render:
    #   <h1>
    #     <span style="color:red">
    #       test
    #     </span>
    #   </h1>
    #
    # Options:
    # [+name+]
    #   The name of the block to render this code around when that block is rendered
    # [+options+]
    #   Any options to specify to the around block when it renders. These will override any options
    #   specified when the block was defined.
    # [+block+]
    #   The block of code to render after another block
    def around(name, options={}, &block)
      self.queue_block_container("around_#{name.to_s}", options, &block)
      nil
    end

    def evaluated_procs(*args)
      options = args.shift.presence || {}
      if options.is_a?(Proc)
        evaluated_proc(options, *args)
      else
        options.inject({}) { |hash, (k, v)| hash[k] = evaluated_proc(v, *args); hash}
      end
    end

    def evaluated_proc(*args)
      return nil unless args.present?
      v = args.shift
      v.is_a?(Proc) ? v.call(*(args[0, v.arity])) : v
    end

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
      self.template_folder = options[:template_folder] ? options.delete(:template_folder) : Blocks.template_folder
      self.variable = (options[:variable] ? options.delete(:variable) : :blocks).to_sym
      self.view = view
      self.global_options = options
      self.queued_blocks = []
      self.blocks = {}
      self.anonymous_block_number = 0
      self.block_groups = {}
      self.use_partials = options[:use_partials].nil? ? Blocks.use_partials : options.delete(:use_partials)
      self.surrounding_tag_surrounds_before_and_after_blocks = options[:surrounding_tag_surrounds_before_and_after_blocks].nil? ? Blocks.surrounding_tag_surrounds_before_and_after_blocks : options.delete(:surrounding_tag_surrounds_before_and_after_blocks)
    end

    # Return a unique name for an anonymously defined block (i.e. a block that has not been given a name)
    def anonymous_block_name
      self.anonymous_block_number += 1
      "block_#{anonymous_block_number}"
    end

    def render_block_with_around_blocks(name_or_container, *args, &block)
      name = name_or_container.is_a?(Blocks::Container) ? name_or_container.name.to_sym : name_or_container.to_sym
      around_name = "around_#{name.to_s}".to_sym

      around_blocks = blocks[around_name].present? ? blocks[around_name].clone : []

      content_block = Proc.new do
        block_container = around_blocks.shift
        if block_container
          view.capture(content_block, *(args[0, block_container.block.arity - 1]), &block_container.block)
        else
          render_block(name_or_container, *args, &block)
        end
      end
      content_block.call
    end

    # Render a block, first trying to find a previously defined block with the same name
    def render_block(name_or_container, *args, &block)
      options = args.extract_options!

      buffer = ActiveSupport::SafeBuffer.new

      block_options = {}
      if (name_or_container.is_a?(Blocks::Container))
        name = name_or_container.name.to_sym
        block_options = name_or_container.options
      else
        name = name_or_container.to_sym
      end

      if blocks[name]
        block_container = blocks[name]
        args.push(global_options.merge(block_container.options).merge(block_options).merge(options))
        buffer << view.capture(*(args[0, block_container.block.arity]), &block_container.block)
      elsif (use_partials || options[:use_partials]) && !options[:skip_partials]
        begin
          begin
            buffer << view.render("#{name.to_s}", global_options.merge(block_options).merge(options))
          rescue ActionView::MissingTemplate
            buffer << view.render("#{self.template_folder}/#{name.to_s}", global_options.merge(block_options).merge(options))
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
      if (name_or_container.is_a?(Blocks::Container))
        name = name_or_container.name.to_sym
        block_options = name_or_container.options
      else
        name = name_or_container.to_sym
        block_options = blocks[name].options if blocks[name]
      end

      before_name = "#{before_or_after}_#{name.to_s}".to_sym
      buffer = ActiveSupport::SafeBuffer.new

      blocks[before_name].each do |block_container|
        args_clone = args.clone
        args_clone.push(global_options.merge(block_options).merge(block_container.options).merge(options))
        buffer << view.capture(*(args_clone[0, block_container.block.arity]), &block_container.block)
      end if blocks[before_name].present?

      buffer
    end

    # Build a Blocks::Container object given the passed in arguments
    def build_block_container(*args, &block)
      options = args.extract_options!
      name = args.first ? args.shift : self.anonymous_block_name
      block_container = Blocks::Container.new
      block_container.name = name.to_sym
      block_container.options = options
      block_container.block = block
      block_container
    end

    # Build a Blocks::Container object and add it to an array of containers matching it's block name
    #  (used only for queuing a collection of before and after blocks for a particular block name)
    def queue_block_container(*args, &block)
      block_container = self.build_block_container(*args, &block)
      if blocks[block_container.name].nil?
        blocks[block_container.name] = [block_container]
      else
        blocks[block_container.name] << block_container
      end
    end

    # Build a Blocks::Container object and add it to the global hash of blocks if a block by the same
    #  name is not already defined
    def define_block_container(*args, &block)
      block_container = self.build_block_container(*args, &block)
      blocks[block_container.name] = block_container if blocks[block_container.name].nil? && block_given?
      block_container
    end

    def content_tag(tag, tag_html, *args, &block)
      if tag
        view.content_tag(tag, block.call, evaluated_procs(tag_html, *args))
      else
        block.call
      end
    end
  end
end
