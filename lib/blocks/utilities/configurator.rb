module Blocks
  module Configurator
    extend ActiveSupport::Concern

    included do
      mattr_accessor :builder_class
      mattr_accessor :renderer_class
      mattr_accessor :global_options_set
      mattr_accessor :lookup_caller_location
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
          config.global_options_set = OptionsSet.new("Global Options")
        end
      end

      def configure
        yield self
      end
    end
  end
end
