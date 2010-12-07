require "blocks"
require "rails"

module Blocks
  class Engine < Rails::Engine
    engine_name :blocks
    initializer "blocks.initialize_helpers" do      
      ActionView::Base.class_eval do
        include Blocks::Helper
      end      
    end
  end
end
