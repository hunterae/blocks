# frozen_string_literal: true

module Blocks
  class BlockDefinition < OptionsSet
    attr_accessor :skip_content,
      :skip_completely,
      :anonymous,
      :hooks

    def initialize(*)
      self.hooks = Hash.new {|hash, key| hash[key] = [] }
      super
    end
              
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

    def hooks_for(hook_type, initialize_when_missing: false)
      hooks[hook_type] if initialize_when_missing || hooks.key?(hook_type)
    end

    def hooks_present?
      hooks.present?
    end

    HookDefinition::HOOKS.each do |hook|
      define_method(hook) do |*args, &hook_definition|
        HookDefinition.new(self, hook, *args, &hook_definition).tap do |definition|
          hooks_for(hook, initialize_when_missing: true) << definition
        end
      end
    end

    # def to_s
    #   description = []
    #   description << super
    #   options = [
    #     standard_options,
    #     default_options
    #   ].detect(&:render_strategy)
    #
    #   strategy = options.try(:render_strategy)
    #   render_strategy_name = if strategy == HashWithRenderStrategy::RENDER_WITH_PROXY
    #     # caller_id = options.callers[HashWithRenderStrategy::RENDER_WITH_PROXY]
    #     "proxy block \"#{options[strategy]}\""
    #   elsif strategy == HashWithRenderStrategy::RENDER_WITH_BLOCK
    #     # caller_id = options.callers[HashWithRenderStrategy::RENDER_WITH_BLOCK]
    #     "block defined at #{options[strategy].source_location}"
    #   elsif strategy == HashWithRenderStrategy::RENDER_WITH_PARTIAL
    #     # caller_id = options.callers[HashWithRenderStrategy::RENDER_WITH_PARTIAL]
    #     "partial \"#{options[strategy]}\""
    #   end
    #   if render_strategy_name
    #     # description << "Renders with #{render_strategy_name} [#{caller_id}]"
    #   end
    #
    #   description.join("\n")
    # end
  end
end