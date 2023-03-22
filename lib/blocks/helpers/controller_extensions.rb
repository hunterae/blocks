# frozen_string_literal: true

require 'active_support/dependencies'

module Blocks
  module ControllerExtensions
    def blocks
      @blocks ||= Blocks.builder_class.new(view_context)
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  include Blocks::ControllerExtensions
end
