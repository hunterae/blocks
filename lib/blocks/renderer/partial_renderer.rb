module Blocks
  class PartialRenderer < AbstractRenderer
    def initialize(builder)
      self.builder = builder
    end

    def render(partial, options={}, &block)
      overrides_and_provided_content = capture_block(builder, &block) if block_given?

      locals = options.delete(:locals) || {}
      locals[options.delete(:builder_variable) || :builder] = builder

      options = Blocks.global_options.merge(init_options).merge(options)

      view.render(layout: partial, locals: locals.merge(options: options)) do |*args|
        if overrides_and_provided_content
          overrides_and_provided_content.to_str.gsub(/PLACEHOLDER_FOR_([\w]+)/) do |s|
            builder.render $1, options
          end.html_safe
        end
      end
    end
  end
end