require "action_view"

$LOAD_PATH.unshift(File.dirname(__FILE__))

require "building_blocks/base"
require "building_blocks/container"
require "building_blocks/helper_methods"

$LOAD_PATH.shift

if defined?(ActionView::Base)
  ActionView::Base.send :include, BuildingBlocks::HelperMethods
end
