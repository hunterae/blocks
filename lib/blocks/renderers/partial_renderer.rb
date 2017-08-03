module Blocks
  class PartialRenderer < AbstractRenderer
    def render(partial, options={}, &block)
      if !options.is_a?(Blocks::RuntimeContext)
        options = RuntimeContext.new(builder, options).to_hash.with_indifferent_access.deep_dup
      end
      overrides_and_provided_content = capture(builder, options, &block) if block_given?
      locals = options.merge(
        (options[:builder_variable] || :builder) => builder,
      ).symbolize_keys
      locals[:options] = options
      view.render(layout: partial, locals: locals) do |*args|
        if overrides_and_provided_content
          overrides_and_provided_content.to_str.gsub(/PLACEHOLDER_FOR_([\w]+)/) do |s|
            builder.render $1, *args
          end.html_safe
        end
      end
    end
  end
end