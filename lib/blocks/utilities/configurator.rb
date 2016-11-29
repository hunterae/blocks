module Blocks
  module Configurator
    extend ActiveSupport::Concern
    include DynamicConfiguration

    included do
      add_config(:builder_class)
      add_config(:renderer_class)
      add_config(:invalid_permissions_approach)
      reset_config
    end

    module ClassMethods
      def reset_config
        self.global_options = HashWithIndifferentAccess.new
        configure do |config|
          config.builder_class = Builder
          config.renderer_class = DefaultRenderer
          config.invalid_permissions_approach = InvalidPermissionsHandler::LOG
        end
      end
    end
  end
end
