module Blocks
  class BlockContainer
    # The name of the block defined (possibly an anonymous name)
    attr_accessor :name

    # Options that are defined when a block's definition is provided by a template
    attr_accessor :default_options

    # Options that are defined by the user of a block
    attr_accessor :runtime_options

    # The actual Ruby block of code
    attr_accessor :block

    # Whether the block is anonymous (doesn't have a user-specified name)
    attr_accessor :anonymous

    attr_accessor :hooks

    def initialize
      self.hooks = HashWithIndifferentAccess.new { |hash, key| hash[key] = []; hash[key] }
      self.runtime_options = HashWithIndifferentAccess.new
      self.default_options = HashWithIndifferentAccess.new
    end

    HOOKS_AND_QUEUEING_TECHNIQUE = [
      [:before_all, :lifo],
      [:around_all, :lifo],
      [:before, :lifo],
      [:around, :lifo],
      [:prepend, :lifo],
      [:append, :fifo],
      [:after, :fifo],
      [:after_all, :fifo]
    ]
    HOOKS_AND_QUEUEING_TECHNIQUE.each do |hook, direction|
      define_method(hook) do |name, options={}, &block|
        block_container = BlockContainer.new
        block_container.name = name
        block_container.runtime_options = options.with_indifferent_access
        block_container.block = block
        # debugger if hook == :around

        if direction == :fifo
          hooks[hook] << block_container
        else
          hooks[hook].unshift block_container
        end
      end
    end
  end
end
