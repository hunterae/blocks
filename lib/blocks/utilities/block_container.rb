module Blocks
  class BlockContainer
    # The name of the block defined (possibly an anonymous name)
    attr_accessor :name

    # The actual Ruby block of code
    attr_accessor :block

    # Whether the block is anonymous (doesn't have a user-specified name)
    attr_accessor :anonymous

    attr_accessor :hooks

    attr_accessor :options_list

    attr_accessor :skip_content

    attr_accessor :skip_all_hooks

    BEFORE_ALL = :before_all
    AROUND_ALL = :around_all
    BEFORE = :before
    AROUND = :around
    SURROUND = :surround
    PREPEND = :prepend
    APPEND = :append
    AFTER = :after
    AFTER_ALL = :after_all

    # Queuing techniques - LIFO and FIFO
    LAST_IN_FIRST_OUT = :lifo
    FIRST_IN_FIRST_OUT = :fifo

    # Before hooks queue items before each other,
    #  i.e. each call to before / prepend will add
    #  items to the front of the list (LIFO) while
    #  all other hooks queue in order
    HOOKS_AND_QUEUEING_TECHNIQUE = {
      BEFORE_ALL => LAST_IN_FIRST_OUT,
      AROUND_ALL => LAST_IN_FIRST_OUT,
      BEFORE => LAST_IN_FIRST_OUT,
      AROUND => LAST_IN_FIRST_OUT,
      SURROUND => LAST_IN_FIRST_OUT,
      PREPEND => LAST_IN_FIRST_OUT,
      APPEND => FIRST_IN_FIRST_OUT,
      AFTER => FIRST_IN_FIRST_OUT,
      AFTER_ALL => FIRST_IN_FIRST_OUT
    }

    HOOKS = HOOKS_AND_QUEUEING_TECHNIQUE.keys

    def initialize
      self.hooks = HashWithIndifferentAccess.new { |hash, key| hash[key] = []; hash[key] }
      self.options_list = []
    end

    def add_options(options)
      # called_by = caller.detect {|c| !c.include?("/lib/blocks")}
      # puts "*****CALLED BY: #{called_by}"
      options_list.unshift options.with_indifferent_access
    end

    def merged_options
      options_list.reduce(HashWithIndifferentAccess.new, :merge)
    end

    def skip(all_hooks=false)
      container.skip_content = true
      container.skip_all_hooks = all_hooks
    end

    HOOKS_AND_QUEUEING_TECHNIQUE.each do |hook, direction|
      define_method(hook) do |name, options={}, &block|
        block_container = BlockContainer.new
        block_container.name = name
        block_container.add_options options.with_indifferent_access
        block_container.block = block

        if direction == FIRST_IN_FIRST_OUT
          hooks[hook] << block_container
        else
          hooks[hook].unshift block_container
        end
      end
    end
  end
end
