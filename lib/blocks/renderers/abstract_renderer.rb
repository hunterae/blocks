module Blocks
  class AbstractRenderer
    RENDERERS = [
      AdjacentBlocksRenderer,
      BlockRenderer,
      BlockWithHooksRenderer,
      CollectionRenderer,
      PartialRenderer,
      NestingBlocksRenderer,
      WrapperRenderer
    ]

    attr_accessor :main_renderer

    delegate :builder, *(RENDERERS.map {|r| r.to_s.demodulize.underscore }), to: :main_renderer
    delegate :block_definitions, :block_for, :view, to: :builder
    delegate :with_output_buffer, :output_buffer, to: :view

    def initialize(main_renderer=nil)
      self.main_renderer = main_renderer
    end

    def render(*args)
      raise NotImplementedError
    end

    def capture(*args, &block)
      without_haml_interference do
        if block.arity > 0
          args = args[0, block.arity]
        end

        with_output_buffer do
          output_buffer << view.capture(*args, &block)
        end
      end
    end

    protected

    # Complete hack to get around issues with Haml
    #  Haml does some hacking to ActionView's with_output_buffer and
    #  output_buffer. In doing so, they make certain assumptions about
    #  the layout and the view template. The Blocks gem doesn't capture
    #  blocks immediately but rather stores them for later capturing.
    #  This can produce an issue if a block that is stored was in Haml
    #  but the Layout is in ERB. Haml will think that any blocks it
    #  captures while rendering the layout will be in ERB format. However,
    #  the block would need to be captured in Haml using a Haml buffer.
    #  This workaround accomplishes that.
    def without_haml_interference(&block)
      if defined?(::Haml) && view.instance_variables.include?(:@haml_buffer)
        haml_buffer = view.instance_variable_get(:@haml_buffer)
        if haml_buffer
          was_active = haml_buffer.active?
          haml_buffer.active = false
        else
          haml_buffer = Haml::Buffer.new(nil, Haml::Options.new.for_buffer)
          haml_buffer.active = false
          kill_buffer = true
          view.instance_variable_set(:@haml_buffer, haml_buffer)
        end
      end
      yield
    ensure
      haml_buffer.active = was_active if haml_buffer
    end
  end
end