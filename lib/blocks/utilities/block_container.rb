module Blocks
  class BlockContainer < RenderingStrategy
    # The name of the block defined (possibly an anonymous name)
    attr_accessor :name

    # Whether the block is anonymous (doesn't have a user-specified name)
    attr_accessor :anonymous

    attr_accessor :hooks

    attr_accessor :skip_content

    attr_accessor :skip_completely

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

    def initialize(parent_block_container=nil, options=nil, &block)
      super(&nil)

      if options.nil?
        self.hooks = HashWithIndifferentAccess.new { |hash, key| hash[key] = []; hash[key] }
      else
        self.name = parent_block_container.name
        self.add_options options, &block
      end
    end

    def add_options(options, &block)
      super(name, options, &block)
    end

    def to_s
      description = []
      block_name = self.name.to_s
      if block_name.include?(" ")
        block_name = ":\"#{block_name}\""
      else
        block_name = ":#{block_name}"
      end
      description << "Block Name: #{block_name}"
      description << super
      description.join("\n")
    end

    def skip(completely=false)
      self.skip_content = true
      self.skip_completely = completely
    end

    HOOKS.each do |hook|
      define_method(hook) do |options={}, &block|
        hooks[hook] << BlockContainer.new(self, options, &block)
      end
    end
  end
end
