module Blocks
  class AbstractRenderer
    include CallWithParams

    RENDERERS = [
      AdjacentBlocksRenderer,
      BlockRenderer,
      BlockWithHooksRenderer,
      CollectionRenderer,
      PartialRenderer,
      NestingBlocksRenderer,
      WrapperRenderer
    ]

    delegate :view,
             :block_containers,
             :init_options,
              to: :builder

    attr_accessor :builder

    def initialize(builder)
      self.builder = builder
    end

    def render(*args)
      raise NotImplementedError
    end

    delegate *(RENDERERS.map do |klass|
      klass.to_s.demodulize.underscore
    end), to: :builder

    protected

    def with_output_buffer
      view.with_output_buffer { yield }
    end

    def output_buffer
      view.output_buffer
    end

    def capture_block(*args, &block)
      without_haml_interference do
        if block.arity > 0
          args = args[0, block.arity]
        end

        with_output_buffer do
          output_buffer << view.capture(*args, &block)
        end
      end
    end

    def block_and_options_to_use(block_container_or_block_name, runtime_options, &default_definition)
      BlockAndOptionsExtractor.new(builder).block_and_options_to_use(block_container_or_block_name, runtime_options, &default_definition)
    end

    def without_haml_interference(&block)
      # Complete hack to get around issues with Haml
      if view.instance_variables.include?(:@haml_buffer)
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