require 'rails/engine'
require 'rails/version'

module Blocks
  class Railtie < Rails::Engine
    if Rails::VERSION::MAJOR >= 4
      config.eager_load_namespaces << Blocks
    else
      config.eager_load_paths += Blocks.autoloads.values
    end
  end
end