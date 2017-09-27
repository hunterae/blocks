module Blocks
  class BlockDefinition < OptionsSet
    attr_accessor :options_set,
                  :skip_content,
                  :skip_completely,
                  :anonymous,
                  *HookDefinition::HOOKS.map {|hook| "#{hook}_hooks" }


    def skip(completely=false)
      self.skip_content = true
      self.skip_completely = completely
    end

    def skip_content?
      !!skip_content
    end

    def skip_completely?
      !!skip_completely
    end

    def hooks_for(hook_name)
      self.send("#{hook_name}_hooks")
    end

    HookDefinition::HOOKS.each do |hook|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{hook}_hooks
          @#{hook}_hooks ||= []
        end
      RUBY

      define_method(hook) do |*args, &block|
        HookDefinition.new(self, hook, *args, &block).tap do |definition|
          hooks_for(hook) << definition
        end
      end
    end

    def to_s
      description = []
      description << super
      options = [
        runtime_options,
        standard_options,
        default_options
      ].detect(&:render_strategy)

      strategy = options.try(:render_strategy)
      render_strategy_name = if strategy == HashWithRenderStrategy::RENDER_WITH_PROXY
        caller_id = options.callers[HashWithRenderStrategy::RENDER_WITH_PROXY]
        "proxy block \"#{options[strategy]}\""
      elsif strategy == HashWithRenderStrategy::RENDER_WITH_BLOCK
        caller_id = options.callers[HashWithRenderStrategy::RENDER_WITH_BLOCK]
        "block defined at #{options[strategy].source_location}"
      elsif strategy == HashWithRenderStrategy::RENDER_WITH_PARTIAL
        caller_id = options.callers[HashWithRenderStrategy::RENDER_WITH_PARTIAL]
        "partial \"#{options[strategy]}\""
      end
      if render_strategy_name
        description << "Renders with #{render_strategy_name} [#{caller_id}]"
      end

      description.join("\n")
    end
  end
end