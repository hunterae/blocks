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

    if defined?(Haml)
      prepend HamlCapture
    end

    attr_accessor :main_renderer

    delegate :builder, *(RENDERERS.map {|r| r.to_s.demodulize.underscore }), to: :main_renderer
    delegate :block_definitions, :block_for, :hooks_for, :view, to: :builder
    delegate :with_output_buffer, :output_buffer, to: :view

    def initialize(main_renderer=nil)
      self.main_renderer = main_renderer
    end

    def render(*args)
      raise NotImplementedError
    end

    def capture(*args, &block)
      if block.arity >= 0
        args = args[0, block.arity]
      end
      with_output_buffer do
        output_buffer << view.capture(*args, &block)
      end
    end
  end
end