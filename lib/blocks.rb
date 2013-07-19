require "action_view"
require "action_controller"

module Blocks
  autoload :Base,          "blocks/base"
  autoload :Container,     "blocks/container"
  autoload :ViewAdditions, "blocks/view_additions"
  autoload :ControllerAdditions, "blocks/controller_additions"

  mattr_accessor :template_folder
  @@template_folder = "blocks"

  mattr_accessor :use_partials
  @@use_partials = false

  mattr_accessor :surrounding_tag_surrounds_before_and_after_blocks
  @@surrounding_tag_surrounds_before_and_after_blocks = false

  # Shortcut for using the templating feature / rendering templates
  def self.render_template(view, partial, options={}, &block)
    Blocks::Base.new(view, options).render_template(partial, &block)
  end

  # Default way to setup Blocks
  def self.setup
    yield self
  end
end

ActionView::Base.send :include, Blocks::ViewAdditions::ClassMethods
ActionController::Base.send :include, Blocks::ControllerAdditions::ClassMethods