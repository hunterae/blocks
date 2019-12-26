# frozen_string_literal: true

module Blocks
  class HookDefinition < HashWithRenderStrategy
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

    attr_accessor :block_definition, :hook_type, :name, :runtime_block

    def initialize(block_definition, hook_type, options, &block)
      self.block_definition = block_definition
      self.hook_type = hook_type
      super &nil
      add_options options
      self.name = self[:render] || self[:with] || "#{hook_type} #{block_definition.name} options"
      # name = self[:render] || "#{hook_type} #{block_definition.name} options"
      # super name, *args, &block

      if block
        if render_strategy
          self.runtime_block = block
        else
          add_options block: block
        end
      end
    end
  end
end