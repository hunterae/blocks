require "action_view"
require "action_controller"
require "call_with_params"
require "hashie"

module Blocks
  autoload :Base,          "blocks/base"
  autoload :Container,     "blocks/container"
  autoload :ViewAdditions, "blocks/view_additions"
  autoload :ControllerAdditions, "blocks/controller_additions"

  mattr_accessor :config
  @@config = Hashie::Mash.new

  # Shortcut for using the templating feature / rendering templates
  def self.render_template(view, partial, options={}, &block)
    Blocks::Base.new(view, options).render_template(partial, &block)
  end

  # Default way to setup Blocks
  def self.setup
    config.template_folder = "blocks"
    config.wrap_before_and_after_blocks = false
    config.use_partials = false
    yield config
  end
end

ActionView::Base.send :include, Blocks::ViewAdditions::ClassMethods
ActionController::Base.send :include, Blocks::ControllerAdditions::ClassMethods