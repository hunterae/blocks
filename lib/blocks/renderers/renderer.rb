module Blocks
  class Renderer
    attr_accessor :builder
    delegate :render, to: :block_with_hooks_renderer

    def initialize(builder)
      self.builder = builder
    end

    # TODO: this needs to be handled by a new renderer
    def render_with_overrides(*args, &block)
      options = args.extract_options!
      name = args.first
      if name.is_a?(Symbol) || name.is_a?(String)
        # TODO: block needs to be handled differently so as to provide overrides
        block_with_hooks_renderer.render(*args, options, &block)
      elsif options[:partial]
        partial_renderer.render(options.delete(:partial), options, &block)
      else
        # TODO: handle other possible rendering methods such as a custom renderer
      end
    end

    # TODO: this needs to be handled by a new renderer
    #  TODO: also get rid of BlockPlaceholder
    def deferred_render(*args, &block)
      block_definition = builder.define(*args, &block)
      Blocks::BlockPlaceholder.new(block_definition)
    end

    AbstractRenderer::RENDERERS.each do |klass|
      name = klass.to_s.demodulize.underscore.to_sym
      define_method name do
        klass.new(self)
      end
    end
  end
end
