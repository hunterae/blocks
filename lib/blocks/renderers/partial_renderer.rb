# frozen_string_literal: true

module Blocks
  class PartialRenderer
    def self.render(runtime_context)
      builder = runtime_context.builder
      view = builder.view
      partial = runtime_context.render_item
      partial = partial.to_partial_path if partial.respond_to?(:to_partial_path)
      runtime_block = runtime_context.runtime_block

      options = runtime_context.to_hash
      overrides_and_provided_content = builder.capture(builder, options, &runtime_context.runtime_block) if runtime_block

      locals = options.merge(
        (runtime_context[:builder_variable] || :builder) => builder,
      )
      locals[:options] = options

      builder.view.render(layout: partial, locals: locals) do |*args|
        if overrides_and_provided_content
          overrides_and_provided_content.to_str.gsub(/PLACEHOLDER_FOR_([\w]+)/) do |s|
            builder.render $1, *args
          end.html_safe
        end
      end
    end
  end
end