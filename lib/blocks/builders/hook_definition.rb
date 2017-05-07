module Blocks
  class HookDefinition < OptionsSet
    BEFORE_ALL = :before_all
    AROUND_ALL = :around_all
    BEFORE = :before
    AROUND = :around
    SURROUND = :surround
    PREPEND = :prepend
    APPEND = :append
    AFTER = :after
    AFTER_ALL = :after_all

    HOOKS = [BEFORE_ALL, BEFORE, PREPEND,
             AROUND_ALL, AROUND, SURROUND,
             APPEND, AFTER, AFTER_ALL]

    attr_accessor :block_definition, :hook_type

    def initialize(block_definition, hook_type, *args, &block)
      self.block_definition = block_definition
      self.hook_type = hook_type
      super "#{hook_type} #{block_definition.name} options", *args, &block
    end
  end
end