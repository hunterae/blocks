module Blocks
  class DefaultRenderer < AbstractRenderer
    def render(*args, &block)
      block_with_hooks_renderer.render(*args, &block)
    end

    def render_with_overrides(*args, &block)
      options = args.extract_options!
      name = args.first
      if name.is_a?(Symbol) || name.is_a?(String)
        options[:overrides] = block
        block_with_hooks_renderer.render(*args, options)
      elsif options[:partial]
        partial_renderer.render(options.delete(:partial), options, &block)
      else
        # TODO
      end
    end
  end
end
