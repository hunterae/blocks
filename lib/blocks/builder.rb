module Blocks
  class Builder
    
    attr_accessor :view, :blocks, :block_positions, :anonymous_block_number,
                  :start_rendering_blocks, :block_groups, :shared_options
    
    def defined?(name)
      !blocks[name.to_sym].nil?
    end
    
    def define(name, options={}, &block)
      block_container = Blocks::Container.new
      block_container.name = name
      block_container.options = options
      block_container.block = block
      
      blocks[name.to_sym] = block_container if blocks[name.to_sym].nil?
      
      nil
    end
    
    def replace(name, options={}, &block)
      block_container = Blocks::Container.new
      block_container.name = name
      block_container.options = options
      block_container.block = block
      
      blocks[name.to_sym] = block_container
      
      nil
    end
  
    def use(*args, &block)      
      options = args.extract_options!      
      
      # If the user doesn't specify a block name, we generate an anonymous block name to assure other
      #  anonymous blocks don't override its definition
      name = args.first ? args.first : self.anonymous_block_name
      
      block_container = Blocks::Container.new
      block_container.name = name
      block_container.options = options
      block_container.block = block

      blocks[name.to_sym] = block_container if !name.is_a?(Blocks::Container) and blocks[name.to_sym].nil? and block
      
      if start_rendering_blocks
        render_block name, options
      else
        # Delays rendering this block until the partial has been rendered and all the blocks have had a chance to be defined
        self.block_positions << block_container 
      end
      
      nil
    end
    
    def render
      self.start_rendering_blocks = false
      
      if shared_options[:block]
        view.capture(self, &shared_options[:block])        
      end
      
      self.start_rendering_blocks = true

      view.render shared_options[:template], shared_options
    end
    
    def before(name, options={}, &block)
      name = "before_#{name.to_s}".to_sym
      
      block_container = Blocks::Container.new
      block_container.name = name
      block_container.options = options
      block_container.block = block
      
      if blocks[name].nil?
        blocks[name] = [block_container]
      else
        blocks[name] << block_container
      end

      nil
    end
    alias prepend before
    
    def after(name, options={}, &block)
      name = "after_#{name.to_s}".to_sym
      
      block_container = Blocks::Container.new
      block_container.name = name
      block_container.options = options
      block_container.block = block
      
      if blocks[name].nil?
        blocks[name] = [block_container]
      else
        blocks[name] << block_container
      end

      nil
    end
    alias append after
    
    # If a method is missing, we'll assume the user is starting a new block group by that missing method name
    def method_missing(m, options={}, &block) 
      # If the specified block group has already been defined, it is simply returned here for iteration.
      #  It will consist of all the blocks used in this block group that have yet to be rendered,
      #   as the call for their use occurred before the template was rendered (where their definitions likely occurred)
      return self.block_groups[m] unless self.block_groups[m].nil?
      
      # Allows for nested block groups, store the current block positions array and start a new one
      original_block_positions = self.block_positions
      self.block_positions = []
      self.block_groups[m] = self.block_positions
     
      # Capture the contents of the block group (this will only capture block definitions and block uses)
      view.capture(shared_options.merge(options), &block) if block_given?
      
      # restore the original block positions array
      self.block_positions = original_block_positions
      nil
    end
    
    protected
    
    def initialize(options)
      self.view = options[:view]
      self.shared_options = options
      
      options[options[:variable] ? options[:variable].to_sym : :blocks] = self
      options[:templates_folder] = "blocks" if options[:templates_folder].nil?
      
      self.block_positions = []
      self.blocks = {}    
      self.anonymous_block_number = 0
      self.block_groups = {}      
      self.start_rendering_blocks = true
    end
    
    def anonymous_block_name
      self.anonymous_block_number = self.anonymous_block_number + 1
      "block_#{anonymous_block_number}"
    end
    
    def render_block(name_or_container, options={})
      render_options = options
      
      if (name_or_container.is_a?(Blocks::Container))
        name = name_or_container.name.to_sym
        render_options = render_options.merge(name_or_container.options)
      else
        name = name_or_container.to_sym
      end
      
      view.concat(render_before_blocks(name, options))
      
      if blocks[name]
        block_container = blocks[name]
        view.concat(view.capture shared_options.merge(block_container.options).merge(render_options), &block_container.block)
      elsif view.blocks.blocks[name]
        block_container = view.blocks.blocks[name]
        view.concat(view.capture shared_options.merge(block_container.options).merge(render_options), &block_container.block)
      else
        begin
          view.concat(view.render "#{shared_options[:templates_folder]}/#{name.to_s}", shared_options.merge(render_options))
        rescue ActionView::MissingTemplate
          # This block does not exist and no partial can be found to satify it
        end
      end
      
      view.concat(render_after_blocks(name, options))
    end
    
    def render_before_blocks(name, options={})
      name = "before_#{name.to_s}".to_sym
      
      unless blocks[name].nil?
        blocks[name].each do |block_container|
          view.concat(view.capture shared_options.merge(block_container.options).merge(options), &block_container.block)
        end
      end
      
      unless view.blocks.blocks[name].nil? || view.blocks.blocks == blocks
        view.blocks.blocks[name].each do |block_container|
          view.concat(view.capture shared_options.merge(block_container.options).merge(options), &block_container.block)
        end
      end
      
      nil
    end
    
    def render_after_blocks(name, options={})
      name = "after_#{name.to_s}".to_sym
      
      unless blocks[name].nil?
        blocks[name].each do |block_container|
          view.concat(view.capture shared_options.merge(block_container.options).merge(options), &block_container.block)
        end
      end
      
      unless view.blocks.blocks[name].nil? || view.blocks.blocks == blocks
        view.blocks.blocks[name].each do |block_container|
          view.concat(view.capture shared_options.merge(block_container.options).merge(options), &block_container.block)
        end
      end
      
      nil
    end
  end
end
