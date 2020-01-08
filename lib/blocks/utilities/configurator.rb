# frozen_string_literal: true

module Blocks
  module Configurator
    extend ActiveSupport::Concern

    included do
      mattr_accessor :builder_class
      mattr_accessor :renderer_class
      mattr_accessor :global_options
      mattr_accessor :lookup_caller_location
      mattr_accessor :track_caller
      # TODO: add default_defintions option
      # TODO: add submodules / extensions option
      # TODO: add option to specify render order for nesting hooks

      # Specifies whether the default options specified for a render call will take priority over ones specified as block default options
      #  Legacy versions of Blocks had default render options always take precedence over block-level default options
      mattr_accessor :default_render_options_take_precedence_over_block_defaults

      # Specifies whether a block defined with a proc will receive a collection item as its first argument when rendering collections
      #  Legacy versions of Blocks assumed that the collection item would be the first argument
      mattr_accessor :collection_item_passed_to_block_as_first_arg

      reset_config
    end

    module ClassMethods
      def reset_config
        configure do |config|
          config.builder_class = Builder
          config.renderer_class = Renderer
          config.lookup_caller_location = false
          config.track_caller = false
          config.global_options = nil
          config.default_render_options_take_precedence_over_block_defaults = false
          config.collection_item_passed_to_block_as_first_arg = false
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
