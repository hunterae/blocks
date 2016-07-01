module Blocks
  class HashWithRenderStrategy < HashWithCaller
    attr_accessor :render_strategy

    RENDER_WITH_PROXY = :with
    RENDER_WITH_BLOCK = :block
    RENDER_WITH_PARTIAL = :partial

    RENDERING_STRATEGIES = [RENDER_WITH_PROXY, RENDER_WITH_BLOCK, RENDER_WITH_PARTIAL]

    def initialize_copy(original)
      super
      self.callers = original.callers.clone
      self.render_strategy = nil
      RENDERING_STRATEGIES.each do |rs|
        self.delete(rs)
      end
    end

    alias_method :dup, :clone

    def reverse_merge(options)
      self.clone.tap {|cloned| cloned.add_options(options) }
    end

    def add_options(*args, &block)
      options = args.extract_options!
      if !options.is_a?(HashWithIndifferentAccess)
        options = options.with_indifferent_access
      end
      options[:block] = block if block
      if render_strategy.nil?
        self.render_strategy = if options.is_a?(HashWithRenderStrategy)
          options.render_strategy
        else
          RENDERING_STRATEGIES.detect {|render_strategy| options[render_strategy].present? }
        end
      end

      super(*args, options)
    end

    def render_strategy_and_item
      [render_strategy, self[render_strategy]] if render_strategy
    end
  end
end