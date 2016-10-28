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

    attr_accessor :skip_completely

    attr_accessor :parent_block_container

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

    def initialize(*args, &block)
      self.hooks = HashWithIndifferentAccess.new { |hash, key| hash[key] = []; hash[key] }
      self.options_list = []

      if args.present?
        options = args.extract_options!
        self.parent_block_container = options.delete(:parent_block_container)
        self.add_options options
        self.name = args.first || parent_block_container.try(:name)
        self.block = block
      end
    end

    def add_options(options)
      # called_by = caller.detect {|c| !c.include?("/lib/blocks")}
      options_list << options.with_indifferent_access
    end

    def merged_options
      options_list.reduce(HashWithIndifferentAccess.new, :reverse_merge)
    end

    def skip(completely=false)
      self.skip_content = true
      self.skip_completely = completely
    end

    HOOKS.each do |hook|
      define_method(hook) do |options={}, &block|
        hooks[hook] << BlockContainer.new(
          options.merge(parent_block_container: self), &block
        )
      end
    end
  end
end
