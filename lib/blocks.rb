require 'active_support/core_ext/hash'
require 'active_support/hash_with_indifferent_access'
require 'blocks/helpers/view_extensions'
require 'blocks/helpers/controller_extensions'

module Blocks
  extend ActiveSupport::Autoload

  # The following classes have no direct references when loading the rest
  #  of the Blocks classes so they must be eager loaded to prevent them
  #  from having to be loaded during the request
  #  (http://blog.plataformatec.com.br/2012/08/eager-loading-for-greater-good/)
  eager_autoload do
    autoload_under 'builders' do
      autoload :BlockDefinition
    end

    autoload_under 'renderers' do
      autoload :RuntimeContext
      autoload :BlockPlaceholder
    end
  end

  autoload_under 'renderers' do
    autoload :Renderer
    autoload :AbstractRenderer
    autoload :PartialRenderer
    autoload :BlockWithHooksRenderer
    autoload :AdjacentBlocksRenderer
    autoload :NestingBlocksRenderer
    autoload :CollectionRenderer
    autoload :WrapperRenderer
    autoload :BlockRenderer
  end

  autoload_under 'builders' do
    autoload :Builder
    autoload :HookDefinition
    autoload :LegacyBuilders
  end

  autoload_under 'utilities' do
    autoload :Configurator
    autoload :OptionsSet
    autoload :HashWithRenderStrategy
    autoload :HashWithCaller
  end

  autoload_under 'helpers' do
    autoload :HamlCapture
  end

  include Configurator
end

require 'blocks/engine'