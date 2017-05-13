module Blocks
  module Configurator
    extend ActiveSupport::Concern

    included do
      include DynamicConfiguration

      add_config :builder_class
      add_config :renderer_class
      add_config :global_options_set
      add_config :lookup_caller_location, instance_predicate: true
      reset_config
    end

    module ClassMethods
      def reset_config
        configure do |config|
          config.builder_class = Builder
          config.renderer_class = Renderer
          config.lookup_caller_location = true
          config.global_options_set = OptionsSet.new("Global Options")
        end
      end
    end
  end
end
