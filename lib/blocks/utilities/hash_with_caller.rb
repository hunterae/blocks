require 'active_support/hash_with_indifferent_access'

module Blocks
  class HashWithCaller < HashWithIndifferentAccess
    attr_accessor :callers

    def initialize(*args)
      self.callers = HashWithIndifferentAccess.new
      super
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
        "\"#{key}\" => #{value_display} [set #{callers[key]}]"
      end.join(",\n")
      description << "}"
      description.join("\n")
    end

    def add_options(*args)
      options = args.extract_options!
      setter = args.first ? "by #{args.first} at " : ""

      setter += caller.detect do |c|
        !c.include?("/lib/blocks") &&
        !c.include?("/lib/ruby") &&
        !c.include?("patch")
      end.try(:split, ":in").try(:[], 0)
      options.each do |key, value|
        current_value = self[key]

        if options.is_a?(HashWithCaller)
          setter = options.callers[key]
        end

        if !self.key?(key)
          self[key] = value
          callers[key] = setter
        elsif value.is_a?(Hash) && current_value.is_a?(Hash)
          self[key] = value.deep_merge(current_value)
          callers[key] = "#{callers[key]}, #{setter}"
          # TODO: handle attribute merges here
        end
      end
    end
  end
end