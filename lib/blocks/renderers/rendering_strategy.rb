module Blocks
  class RenderingStrategy < HashWithCaller
    attr_accessor :render_strategy

    RENDER_WITH_PROXY = :with
    RENDER_WITH_BLOCK = :block
    RENDER_WITH_PARTIAL = :partial

    RENDERING_STRATEGIES = [RENDER_WITH_PROXY, RENDER_WITH_BLOCK, RENDER_WITH_PARTIAL]

    def add_options(*args, &block)
      options = args.extract_options!
      if !options.is_a?(HashWithIndifferentAccess)
        options = options.with_indifferent_access
      end
      options[:block] = block if block
      if render_strategy.nil?
        self.render_strategy = if options.is_a?(RenderingStrategy)
          options.render_strategy
        else
          RENDERING_STRATEGIES.detect {|render_strategy| options[render_strategy].present? }
        end
      end

      super(*args, options)
    end

    def uses_proxy?
      render_strategy == RENDER_WITH_PROXY
    end

    def proxy
      self[RENDER_WITH_PROXY]
    end

    def uses_block?
      render_strategy == RENDER_WITH_BLOCK
    end

    def block
      self[RENDER_WITH_BLOCK]
    end

    def uses_partial?
      render_strategy == RENDER_WITH_PARTIAL
    end

    def partial
      self[RENDER_WITH_PARTIAL]
    end

    def to_s
      description = []
      render_strategy_name = if uses_proxy?
        caller_id = callers[RENDER_WITH_PROXY]
        "proxy block \"#{self[RENDER_WITH_PROXY]}\""
      elsif uses_block?
        caller_id = callers[RENDER_WITH_BLOCK]
        "block defined at #{self[RENDER_WITH_BLOCK].source_location}"
      elsif uses_partial?
        caller_id = callers[RENDER_WITH_PARTIAL]
        "partial \"#{self[RENDER_WITH_PARTIAL]}\""
      end
      description << "Renders with #{render_strategy_name} [set #{caller_id}]"

      description << super
      description.join("\n")
    end
  end
end