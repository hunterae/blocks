require 'active_support/core_ext/hash'
require 'active_support/hash_with_indifferent_access'
require 'blocks/action_view_extensions/view_extensions'

module Blocks
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload_under 'renderers' do
      autoload :Renderer
      autoload :RuntimeContext
      autoload :AbstractRenderer
      autoload :PartialRenderer
      autoload :BlockWithHooksRenderer
      autoload :AdjacentBlocksRenderer
      autoload :NestingBlocksRenderer
      autoload :CollectionRenderer
      autoload :WrapperRenderer
      autoload :BlockRenderer
      autoload :BlockPlaceholder
    end

    autoload_under 'builders' do
      autoload :HookDefinition
      autoload :BlockDefinition
      autoload :Builder
    end

    autoload_under 'utilities' do
      autoload :DynamicConfiguration
      autoload :Configurator
      autoload :OptionsSet
      autoload :HashWithRenderStrategy
      autoload :HashWithCaller
    end
  end

  # WIP
  # autoload_under 'experimental' do
  #   autoload :BuilderPermissions
  #   autoload :InvalidPermissionsHandler
  # end

  autoload :Version

  include Configurator
end
