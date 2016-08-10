module Blocks
  class AbstractRenderer
    include ActionView::Helpers::CaptureHelper
    include CallWithParams
    include HamlHelpers

    delegate :view,
             :block_containers,
             :init_options,
             :definition_mode=,
              to: :builder

    attr_accessor :output_buffer
    attr_accessor :builder

    def initialize(builder)
      self.builder = builder
    end

    def render(*args)
      raise NotImplementedError
    end

    protected
    def capture_block(*args, &block)
      without_haml_interference { view.capture(*(args[0, block.arity]), &block) }
    end

    def block_and_options_to_use(block_container_or_block_name, runtime_options, &default_definition)
      BlockAndOptionsExtractor.new(builder).block_and_options_to_use(block_container_or_block_name, runtime_options, &default_definition)
    end
  end
end