module Blocks
  class Renderer < AbstractRenderer
    def render(*args, &block)
      BlockWithHooksRenderer.new(builder).render(*args, &block)
    end

    def render_with_overrides(*args, &block)
      name = args.first
      options = args.extract_options!
      if name.is_a?(Symbol) || name.is_a?(String)
        options[:overrides] = block
        BlockWithHooksRenderer.new(builder).render(*args, options)
      elsif options[:partial]
        PartialRenderer.new(builder).render(options.delete(:partial), &block)
      else
        # TODO
      end
    end
  end
end
