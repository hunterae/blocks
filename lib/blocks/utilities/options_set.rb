# frozen_string_literal: true

module Blocks
  class OptionsSet < HashWithRenderStrategy
    attr_accessor :name
    attr_accessor :default_options

    def initialize(*args, &block)
      super
      self.name = args.first
    end

    # def to_s
    #   description = []
    #   description << "Block Name: #{name}"
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
      hash = to_hash
      hash[:defaults] = default_options.to_hash if default_options.present?
      hash
    end

    def reverse_merge!(*args, &block)
      options = args.extract_options!
      caller_id = args.first

      defaults, standard = if options.is_a?(OptionsSet)
        caller_id ||= options.name
        [options.default_options, options]
      else
        [options.delete(:defaults), options]
      end

      caller_id ||= self.name

      if standard.present? || block
        super caller_id, standard, &block
      end

      if defaults.present?
        if !default_options
          self.default_options = HashWithRenderStrategy.new "#{name} Default Options"
        end
        default_options.reverse_merge! caller_id, defaults
      end

      self
    end

    def renders_with_proxy?
      render_strategy == HashWithRenderStrategy::RENDER_WITH_PROXY
    end

    def render_strategy
      super || default_options.try(:render_strategy)
    end

    def render_strategy_item
      super || default_options.try(:render_strategy_item)
    end
  end
end