# frozen_string_literal: true

module Blocks
  class OptionsSet < Hash
    attr_accessor :name

    attr_accessor :runtime_options
    attr_accessor :standard_options
    attr_accessor :default_options

    def initialize(*args, &block)
      options = args.extract_options!
      self.name = args.first
      self.runtime_options = HashWithRenderStrategy.new "#{name} Runtime Options"
      self.standard_options = HashWithRenderStrategy.new "#{name} Standard Options"
      self.default_options = HashWithRenderStrategy.new "#{name} Default Options"
      add_options options, &block
      super(&nil)
    end

    def initialize_copy(original)
      super
      control_fields = (
        RuntimeContext::CONTROL_VARIABLES.keys +
        RuntimeContext::CONTROL_VARIABLES.values
      ).flatten.compact
      self.runtime_options = original.runtime_options.clone.except(*control_fields)
      self.default_options = original.default_options.clone.except(*control_fields)
      self.standard_options = original.standard_options.clone.except(*control_fields)
    end

    # def to_s
    #   description = []
    #   description << "Block Name: #{name}"
    #   description << "------------------------------"
    #   description << "Runtime Options:"
    #   description << runtime_options.to_s
    #   description << "------------------------------"
    #   description << "Standard Options:"
    #   description << standard_options.to_s
    #   description << "------------------------------"
    #   description << "Default Options:"
    #   description << default_options.to_s
    #   description.join("\n")
    # end
    #
    def inspect
      hash = standard_options.to_hash.dup
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
        [options.delete(:runtime), options.delete(:defaults), options]
      end

      caller_id ||= self.name

      runtime_options.add_options caller_id, runtime
      standard_options.add_options caller_id, standard, &block
      default_options.add_options caller_id, defaults

      self
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

    # Returns +true+ so that <tt>Array#extract_options!</tt> finds members of
    # this class.
    def extractable_options?
      true
    end

    def nested_under_indifferent_access
      self
    end
  end
end