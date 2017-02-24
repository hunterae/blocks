require 'active_support/hash_with_indifferent_access'
require 'blocks/action_view_extensions/view_extensions'

module Blocks
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload_under 'renderers' do
      autoload :RenderingStrategy
      autoload :RuntimeContext
      autoload :DefaultRenderer
      autoload :PartialRenderer
      autoload :BlockWithHooksRenderer
      autoload :AdjacentBlocksRenderer
      autoload :NestingBlocksRenderer
      autoload :CollectionRenderer
      autoload :WrapperRenderer
      autoload :BlockRenderer
      autoload :AbstractRenderer
    end

    autoload_under 'builders' do
      autoload :Builder
      autoload :BuilderPermissions
    end

    autoload_under 'utilities' do
      autoload :DynamicConfiguration
      autoload :Configurator
      autoload :BlockContainer
      autoload :BlockPlaceholder
      autoload :InvalidPermissionsHandler
      autoload :HashWithCaller
    end
  end

  autoload :Version

  include Configurator
end
