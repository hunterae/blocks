module Blocks
  class Renderer < AbstractRenderer
    def render(*args, &block)
      # name = args.first
      # if name.is_a?(Symbol) || name.is_a?(String)
        BlockWithHooksRenderer.new(builder).render(*args, &block)
      # else
        # options = args.extract_options!
      # end
    end

    def render_with_overrides(*args, &block)
      # without_haml_interference do
        name = args.first
        options = args.extract_options!
        if name.is_a?(Symbol) || name.is_a?(String)
          BlockWithHooksRenderer.new(builder).render(*args, options.merge(overrides: true), &block)
        elsif options[:partial]
          PartialRenderer.new(builder).render(options.delete(:partial), &block)
        else
          # TODO
        end
      # end
    end
  end
end
