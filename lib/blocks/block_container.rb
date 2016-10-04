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

    LAST_IN_FIRST_OUT = :lifo
    FIRST_IN_FIRST_OUT = :fifo

    def initialize
      self.hooks = HashWithIndifferentAccess.new { |hash, key| hash[key] = []; hash[key] }
      self.options_list = []
    end

    def add_options(options)
      self.options_list.unshift options.with_indifferent_access
    end

    def merged_options
      options_list.reduce(HashWithIndifferentAccess.new, :merge)
    end

    HOOKS_AND_QUEUEING_TECHNIQUE = [
      [:before_all, LAST_IN_FIRST_OUT],
      [:around_all, LAST_IN_FIRST_OUT],
      [:before, LAST_IN_FIRST_OUT],
      [:around, LAST_IN_FIRST_OUT],
      [:surround, LAST_IN_FIRST_OUT],
      [:prepend, LAST_IN_FIRST_OUT],
      [:append, FIRST_IN_FIRST_OUT],
      [:after, FIRST_IN_FIRST_OUT],
      [:after_all, FIRST_IN_FIRST_OUT]
    ]

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
