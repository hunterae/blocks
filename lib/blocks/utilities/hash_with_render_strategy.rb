# frozen_string_literal: true

module Blocks
  class HashWithRenderStrategy < Hash
    attr_accessor :render_strategy

    RENDER_WITH_PROXY = :with
    RENDER_WITH_BLOCK = :block
    RENDER_WITH_PARTIAL = :partial

    RENDERING_STRATEGIES = [RENDER_WITH_PROXY, RENDER_WITH_PARTIAL, RENDER_WITH_BLOCK]

    def initialize(*args)
      options = args.extract_options!
      add_options(args.first, options)
      super &nil
    end

    def clone
      except(*RENDERING_STRATEGIES)
    end
    alias_method :dup, :clone

    def to_hash
      {}.update(except(RENDERING_STRATEGIES))
    end

    def slice(*keys)
      self.class.new(super)
    end

    def reverse_merge(options)
      self.clone.tap {|cloned| cloned.add_options(options) }
    end

    # TODO: need to implement either merge or update to update
    def reverse_merge!(*args, &block)
      options = args.extract_options!
      options[:block] = block if block
      if render_strategy.nil?
        self.render_strategy = if options.is_a?(HashWithRenderStrategy)
          options.render_strategy
        else
          RENDERING_STRATEGIES.detect {|render_strategy| options[render_strategy].present? }
        end
      end

      options.each do |key, value|
        current_value = self[key]

        if !self.key?(key)
          self[key] = value
        elsif current_value.is_a?(Hash) && value.is_a?(Hash)
          # TODO: handle attribute merges here
          self[key] = value.deep_merge(current_value)
        end
      end
    end
    alias_method :add_options, :reverse_merge!

    def render_strategy_and_item
      [render_strategy, self[render_strategy]] if render_strategy
    end

    def nested_under_indifferent_access
      self
    end

    # Returns +true+ so that <tt>Array#extract_options!</tt> finds members of
    # this class.
    def extractable_options?
      true
    end

    def to_s
      description = []

      description << "{"
      description << map do |key, value|
        value_display = case value
        when Symbol
          ":#{value}"
        when String
          "\"#{value}\""
        when Proc
          "Proc"
        else
          value
        end
        # "\"#{key}\" => #{value_display}, # [#{callers[key]}]"
        "\"#{key}\" => #{value_display}"
      end.join(",\n")
      description << "}"
      description.join("\n")
    end
  end
end