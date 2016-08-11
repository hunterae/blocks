module Blocks
  class AbstractRenderer
    # include ActionView::Helpers::CaptureHelper
    include CallWithParams
    # include Haml::Helpers if defined?(Haml)

    delegate :view,
             :block_containers,
             :init_options,
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
    # def with_output_buffer(&block)
    #   without_haml_interference { super(&block) }
    # end

    def with_output_buffer
      view.with_output_buffer { yield }
    end

    def output_buffer
      view.output_buffer
    end

    def capture_block(*args, &block)
      # view.capture(*(args[0, block.arity]), &block)
      without_haml_interference { view.capture(*(args[0, block.arity]), &block) }
      # if respond_to?(:capture_without_haml)
        # capture_without_haml(*(args[0, block.arity]), &block)
      # else
        # capture(*(args[0, block.arity]), &block)
      # end
    end

    def block_and_options_to_use(block_container_or_block_name, runtime_options, &default_definition)
      BlockAndOptionsExtractor.new(builder).block_and_options_to_use(block_container_or_block_name, runtime_options, &default_definition)
    end

    def without_haml_interference
      if view.respond_to?(:non_haml)
        view.non_haml { yield }
      else
        yield
      end
    end
  end
end