require 'blocks/view_additions'
require 'rails/railtie'

module Blocks
  extend ActiveSupport::Autoload

  autoload :GlobalConfiguration
  autoload :Builder
  autoload :Renderer
  autoload :Container
  autoload :Version

  mattr_accessor :global_options
  @@global_options = GlobalConfiguration.new

  # Default way to setup Blocks
  def self.setup
    yield global_options
  end
end

require 'blocks/railtie' if defined?(Rails)
