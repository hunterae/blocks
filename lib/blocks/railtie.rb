module Blocks
  class Railtie < Rails::Railtie
    config.eager_load_namespaces << Blocks
  end
end
