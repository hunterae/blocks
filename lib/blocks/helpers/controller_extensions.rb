# frozen_string_literal: true

require 'action_controller'

module Blocks
  module ControllerExtensions
    def blocks
      @blocks ||= Blocks.builder_class.new(view_context)
    end
  end
end

ActionController::Base.send :include, Blocks::ControllerExtensions
