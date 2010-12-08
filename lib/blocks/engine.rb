require "blocks"
require "rails"

module Blocks
  class Engine < Rails::Engine
    initializer "blocks.initialize_helpers" do
      ActiveSupport.on_load(:action_view) do
        include Blocks::HelperMethods
      end
    end
  end
end
