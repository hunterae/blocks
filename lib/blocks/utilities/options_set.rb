module Blocks
  class OptionsSet < HashWithIndifferentAccess
    attr_accessor :name

    attr_accessor :runtime_options
    attr_accessor :standard_options
    attr_accessor :default_options

    def initialize(*args, &block)
      options = args.extract_options!
      self.name = args.first
      reset
      add_options options, &block
      super(&nil)
    end

    def to_s
      description = []
      description << "Block Name: #{name}"
      description << "------------------------------"
      description << "Runtime Options:"
      description << runtime_options.to_s
      description << "------------------------------"
      description << "Standard Options:"
      description << standard_options.to_s
      description << "------------------------------"
      description << "Default Options:"
      description << default_options.to_s
      description.join("\n")
    end

    def inspect
      hash = standard_options.to_hash
      hash[:defaults] = default_options if default_options.present?
      hash[:runtime] = runtime_options if runtime_options.present?
      hash
    end

    def add_options(*args, &block)
      options = args.extract_options!
      caller_id = args.first

      runtime, defaults, standard = if options.is_a?(OptionsSet)
        caller_id ||= options.name
        [options.runtime_options, options.default_options, options.standard_options]
      else
        if !options.is_a?(HashWithIndifferentAccess)
          options = options.with_indifferent_access
        end
        [options.delete(:runtime), options.delete(:defaults), options]
      end

      caller_id ||= self.name

      runtime_options.add_options caller_id, runtime
      standard_options.add_options caller_id, standard, &block
      default_options.add_options caller_id, defaults

      self
    end

    def reset
      self.runtime_options = HashWithRenderStrategy.new "#{name} Runtime Options"
      self.standard_options = HashWithRenderStrategy.new "#{name} Standard Options"
      self.default_options = HashWithRenderStrategy.new "#{name} Default Options"
    end

    def current_render_strategy_and_item
      render_strategies_and_items.compact.first
    end

    def render_strategies_and_items
      [
        runtime_options.render_strategy_and_item,
        standard_options.render_strategy_and_item,
        default_options.render_strategy_and_item
      ]
    end
  end
end