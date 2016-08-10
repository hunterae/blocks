require 'blocks/view_additions'
require 'rails/railtie'

module Blocks
  extend ActiveSupport::Autoload

  autoload :GlobalConfiguration
  autoload :Builder
  autoload :BlockContainer
  autoload :Version
  autoload :BlockAndOptionsExtractor

  autoload_under 'renderer' do
    autoload :AbstractRenderer
    autoload :Renderer
    autoload :PartialRenderer
    autoload :BlockWithHooksRenderer
    autoload :AdjacentBlocksRenderer
    autoload :SurroundingBlocksRenderer
  end

  mattr_accessor :global_options
  @@global_options = GlobalConfiguration.new

  # Default way to setup Blocks
  def self.setup
    yield global_options
  end
end
