module Blocks
  module Configurator
    extend ActiveSupport::Concern

    included do
      mattr_accessor :builder_class
      mattr_accessor :renderer_class
      mattr_accessor :global_options_set
      mattr_accessor :lookup_caller_location
      mattr_accessor :track_caller
      # TODO: add default_defintions option
      # TODO: add submodules / extensions option
      # TODO: add option to specify render order for nesting hooks
      reset_config
    end

    module ClassMethods
      def reset_config
        configure do |config|
          config.builder_class = Builder
          config.renderer_class = Renderer
          config.lookup_caller_location = false
          config.track_caller = false
          config.global_options_set = OptionsSet.new("Global Options")
        end
      end

      def configure
        yield self
        self.track_caller = true if lookup_caller_location
        if track_caller
          HashWithRenderStrategy.send(:prepend, HashWithCaller)
        end
      end
    end
  end
end
