require 'blocks/view_additions'

module Blocks
  extend ActiveSupport::Autoload

  autoload :GlobalConfiguration

  eager_autoload do
    autoload :Builder
    autoload :Renderer
    autoload :Container
  end

  mattr_accessor :global_options
  @@global_options = GlobalConfiguration.new

  # Default way to setup Blocks
  def self.setup
    yield global_options
  end
end

require 'blocks/railtie' if defined?(Rails)
