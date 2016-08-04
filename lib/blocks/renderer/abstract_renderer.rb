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
  end
end