module Blocks
  module Configurator
    extend ActiveSupport::Concern

    included do
      include DynamicConfiguration
      singleton_class.class_eval do
        remove_possible_method(:global_options)
        global_options = HashWithIndifferentAccess.new
        define_method(:global_options) do
          global_options
        end
      end

      add_config(:builder_class)
      add_config(:renderer_class)
      add_config(:invalid_permissions_approach)
      reset_config
    end

    module ClassMethods
      def reset_config
        self.global_options.clear
        configure do |config|
          config.builder_class = Builder
          config.renderer_class = DefaultRenderer
          config.invalid_permissions_approach = InvalidPermissionsHandler::LOG
        end
      end
    end
  end
end
