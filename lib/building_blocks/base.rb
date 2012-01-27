module BuildingBlocks
  class Base
    attr_accessor :view

    attr_accessor :blocks

    attr_accessor :block

    # Array of BuildingBlocks::Container objects, storing the order of blocks as they were used
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
      options = args.extract_options!

      # If the user doesn't specify a block name, we generate an anonymous block name to assure other
      #  anonymous blocks don't override its definition
      name = args.first ? args.shift : self.anonymous_block_name

      # self.define_block_container(name, options, &block) if block_given?
      self.render_block name, args, options, &block
    end

    def queue(*args, &block)
      options = args.extract_options!

      # If the user doesn't specify a block name, we generate an anonymous block name to assure other
      #  anonymous blocks don't override its definition
      name = args.first ? args.shift : self.anonymous_block_name

      # Delays rendering this block until the partial has been rendered and all the blocks have had a chance to be defined
      self.queued_blocks << self.define_block_container(name, options, &block)
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
      name = "before_#{name.to_s}".to_sym

      block_container = BuildingBlocks::Container.new
      block_container.name = name
      block_container.options = options
      block_container.block = block

      if view.blocks.blocks[name].nil?
        blocks[name] = [block_container]
      else
        blocks[name] << block_container
      end

      nil
    end
    alias prepend before

    def after(name, options={}, &block)
      name = "after_#{name.to_s}".to_sym

      block_container = BuildingBlocks::Container.new
      block_container.name = name
      block_container.options = options
      block_container.block = block

      if view.blocks.blocks[name].nil?
        blocks[name] = [block_container]
      else
        blocks[name] << block_container
      end

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
      options[:templates_folder] = "blocks" if options[:templates_folder].nil?

      self.view = view
      self.global_options = options
      self.block = block
      self.queued_blocks = []
      self.blocks = {}
      self.anonymous_block_number = 0
      self.block_groups = {}
    end

    def anonymous_block_name
      self.anonymous_block_number = self.anonymous_block_number + 1
      "block_#{anonymous_block_number}"
    end

    def render_block(name_or_container, args, runtime_options={}, &block)
      buffer = ActiveSupport::SafeBuffer.new

      block_options = {}
      if (name_or_container.is_a?(BuildingBlocks::Container))
        name = name_or_container.name.to_sym
        block_options = name_or_container.options
      else
        name = name_or_container.to_sym
      end

      buffer << render_before_blocks(name_or_container, runtime_options)

      if blocks[name]
        block_container = blocks[name]

        args.push(global_options.merge(block_container.options).merge(block_options).merge(runtime_options))

        # If the block is taking more than one parameter, we can use *args
        if block_container.block.arity > 1
          buffer << view.capture(*args, &block_container.block)

        # However, if the block only takes a single parameter, we do not want ruby to try to cram the args list into that parameter
        #   as an array
        else
          buffer << view.capture(args.first, &block_container.block)
        end
      elsif view.blocks.blocks[name]
        block_container = view.blocks.blocks[name]

        args.push(global_options.merge(block_container.options).merge(block_options).merge(runtime_options))

        # If the block is taking more than one parameter, we can use *args
        if block_container.block.arity > 1
          buffer << view.capture(*args, &block_container.block)

        # However, if the block only takes a single parameter, we do not want ruby to try to cram the args list into that parameter
        #   as an array
        else
          buffer << view.capture(args.first, &block_container.block)
        end
      else
        begin
          begin            
            buffer << view.render("#{name.to_s}", global_options.merge(block_options).merge(runtime_options))
          rescue ActionView::MissingTemplate            
            # This partial did not exist in the current controller's view directory; now checking in the default templates folder
            buffer << view.render("#{self.global_options[:templates_folder]}/#{name.to_s}", global_options.merge(block_options).merge(runtime_options))
          end
        rescue ActionView::MissingTemplate
          if block_given?
            args.push(global_options.merge(runtime_options))
            if block.arity > 1
              buffer << view.capture(*args, &block)
            else
              buffer << view.capture(args.first, &block)
            end
          end
        end
      end

      buffer << render_after_blocks(name_or_container, runtime_options)

      buffer
    end

    def render_before_blocks(name_or_container, runtime_options={})
      options = global_options

      block_options = {}
      if (name_or_container.is_a?(BuildingBlocks::Container))
        name = name_or_container.name.to_sym
        block_options = name_or_container.options
      else
        name = name_or_container.to_sym
      end

      before_name = "before_#{name.to_s}".to_sym

      if blocks[name]
        block_container = blocks[name]
        options = options.merge(block_container.options)
      elsif view.blocks.blocks[name]
        block_container = view.blocks.blocks[name]
        options = options.merge(block_container.options)
      end

      buffer = ActiveSupport::SafeBuffer.new

      unless blocks[before_name].nil?
        blocks[before_name].each do |block_container|
          buffer << view.capture(options.merge(block_container.options).merge(block_options).merge(runtime_options), &block_container.block)
        end
      end

      unless view.blocks.blocks[before_name].nil? || view.blocks.blocks == blocks
        view.blocks.blocks[before_name].each do |block_container|
          buffer << view.capture(options.merge(block_container.options).merge(block_options).merge(runtime_options), &block_container.block)
        end
      end

      buffer
    end

    def render_after_blocks(name_or_container, runtime_options={})
      options = global_options

      block_options = {}
      if (name_or_container.is_a?(BuildingBlocks::Container))
        name = name_or_container.name.to_sym
        block_options = name_or_container.options
      else
        name = name_or_container.to_sym
      end

      after_name = "after_#{name.to_s}".to_sym

      if blocks[name]
        block_container = blocks[name]

        options = options.merge(block_container.options)
      elsif view.blocks.blocks[name]
        block_container = view.blocks.blocks[name]

        options = options.merge(block_container.options)
      end

      buffer = ActiveSupport::SafeBuffer.new

      unless blocks[after_name].nil?
        blocks[after_name].each do |block_container|
          buffer << view.capture(options.merge(block_container.options).merge(block_options).merge(runtime_options), &block_container.block)
        end
      end

      unless view.blocks.blocks[after_name].nil? || view.blocks.blocks == blocks
        view.blocks.blocks[after_name].each do |block_container|
          buffer << view.capture(options.merge(block_container.options).merge(block_options).merge(runtime_options), &block_container.block)
        end
      end

      buffer
    end

    def define_block_container(name, options, &block)
      block_container = BuildingBlocks::Container.new
      block_container.name = name
      block_container.options = options
      block_container.block = block
      blocks[name.to_sym] = block_container if blocks[name.to_sym].nil? && block_given?
      block_container
    end
  end
end
