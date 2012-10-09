require "action_view"

module BuildingBlocks
  autoload :Base,          "building_blocks/base"
  autoload :Container,     "building_blocks/container"
  autoload :ViewAdditions, "building_blocks/view_additions"

  mattr_accessor :template_folder
  @@template_folder = "blocks"

  mattr_accessor :use_partials
  @@use_partials = true

  mattr_accessor :surrounding_tag_surrounds_before_and_after_blocks
  @@surrounding_tag_surrounds_before_and_after_blocks = true

  # Shortcut for using the templating feature / rendering templates
  def self.render_template(view, partial, options={}, &block)
    BuildingBlocks::Base.new(view, options).render_template(partial, &block)
  end

  # Default way to setup BuildingBlocks
  def self.setup
    yield self
  end
end

ActionView::Base.send :include, BuildingBlocks::ViewAdditions::ClassMethods