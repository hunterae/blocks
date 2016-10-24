require 'active_support/all'
require 'blocks/action_view_extensions/view_extensions'

module Blocks
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload_under 'builders' do
      autoload :Builder
    end

    autoload_under 'renderers' do
      autoload :AbstractRenderer
      autoload :DefaultRenderer
      autoload :PartialRenderer
      autoload :BlockWithHooksRenderer
      autoload :AdjacentBlocksRenderer
      autoload :SurroundingBlocksRenderer
    end

    autoload_under 'utilities' do
      autoload :BlockAndOptionsExtractor
      autoload :Configurator
      autoload :BlockContainer
    end
  end

  autoload :Version

  include Configurator
end
