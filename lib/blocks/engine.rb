require "blocks"
require "rails"

module Blocks
  class Engine < Rails::Engine
    initializer "blocks.initialize" do
      ActiveSupport.on_load(:action_view) do
        include Blocks::Helper
      end
    end
  end
end
