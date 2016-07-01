module Blocks
  class Container
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
  end
end
