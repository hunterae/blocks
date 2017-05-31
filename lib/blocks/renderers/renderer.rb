module Blocks
  class Renderer
    attr_accessor :builder

    def initialize(builder)
      self.builder = builder
    end

    def render(*args, &block)
      block_with_hooks_renderer.render(*args, &block)
    end

    # TODO: this needs to be handled by a new renderer
    def render_with_overrides(*args, &block)
      options = args.extract_options!
      name = args.first
      if name.is_a?(Symbol) || name.is_a?(String)
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
      name = klass.to_s.demodulize.underscore

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{name}
          @#{name} ||= #{klass}.new(self)
        end
      RUBY
    end
  end
end
