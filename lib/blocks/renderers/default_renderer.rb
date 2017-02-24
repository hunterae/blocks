module Blocks
  class DefaultRenderer < AbstractRenderer
    def render(*args, &block)
      render_block_with_hooks(*args, &block)
    end

    def render_with_overrides(*args, &block)
      options = args.extract_options!
      name = args.first
      if name.is_a?(Symbol) || name.is_a?(String)
        render_block_with_hooks(*args, options, &block)
      elsif options[:partial]
        render_partial(options.delete(:partial), options, &block)
      else
        # TODO
      end
    end
  end
end
