# frozen_string_literal: true

module Blocks
  module HashWithCaller
    attr_accessor :callers

    def initialize(*args)
      self.callers = {}
      super
    end

    def initialize_copy(original)
      super
      self.callers = original.callers.clone
    end

    # TODO: implement inspect

    # TODO: fix and test this implementation
    # def to_s
    #   description = []
    #
    #   description << "{"
    #   description << map do |key, value|
    #     value_display = case value
    #     when Symbol
    #       ":#{value}"
    #     when String
    #       "\"#{value}\""
    #     when Proc
    #       "Proc"
    #     else
    #       value
    #     end
    #     "\"#{key}\" => #{value_display}, # [#{callers[key]}]"
    #   end.join(",\n")
    #   description << "}"
    #   description.join("\n")
    # end

    def reverse_merge!(*args)
      options = args.extract_options!

      caller_id = args.first.to_s.presence || ""

      if !options.is_a?(HashWithCaller) && Blocks.lookup_caller_location
        caller_location = caller.detect do |c|
          !c.include?("/lib/blocks") &&
          !c.include?("/lib/ruby") &&
          !c.include?("patch")
        end.try(:split, ":in").try(:[], 0)

        caller_id += " from #{caller_location}" if caller_location
      end

      options.each do |key, value|
        current_value = self[key]

        if options.is_a?(HashWithCaller)
          setter = options.callers[key]
        else
          setter = "set by #{caller_id}"
        end

        if !self.key?(key)
          callers[key] = setter

        elsif current_value.is_a?(Hash) && value.is_a?(Hash)
          # self[key] = value.deep_merge(current_value)
          callers[key] = "#{callers[key]}, #{setter}"
        end
      end

      super options
    end
  end
end