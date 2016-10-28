module Blocks
  module Configurator
    extend ActiveSupport::Concern

    included do
      mattr_accessor :global_options
      add_config(:builder_class)
      add_config(:renderer_class)
      reset_config
    end

    module ClassMethods
      def add_config(name)
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def self.#{name}
            global_options["#{name}"]
          end

          def self.#{name}=(value)
            global_options["#{name}"]=value
          end

          def #{name}
            self.class.#{name}
          end

          def #{name}=(value)
            self.class.#{name}=value
          end
        RUBY
      end

      def configure
        yield self
      end

      def reset_config
        self.global_options = HashWithIndifferentAccess.new
        configure do |config|
          config.builder_class = Builder
          config.renderer_class = DefaultRenderer
        end
      end
    end
  end
end
