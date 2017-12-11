module Blocks
  class PartialRenderer < AbstractRenderer
    def render(partial, options={}, &block)
      if !options.is_a?(Blocks::RuntimeContext)
        options = RuntimeContext.new(builder, options).to_hash.with_indifferent_access
      end
      overrides_and_provided_content = capture(builder, options, &block) if block_given?
      locals = options.merge(
        (options[:builder_variable] || :builder) => builder,
      )
      locals = if locals.respond_to?(:deep_symbolize_keys)
        locals.deep_symbolize_keys
      else
        locals.symbolize_keys
      end
      partial = partial.to_partial_path if partial.respond_to?(:to_partial_path)
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