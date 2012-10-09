require 'rubygems'
require 'bundler/setup'

require 'building-blocks' # and any other gems you need

def print_hash(hash)
  hash.inject("") { |s, (k, v)| "#{s} #{k}: #{v}." }
end

RSpec.configure do |config|
  config.mock_with :mocha
  
  config.before :each do
    BuildingBlocks.template_folder = "blocks"
    BuildingBlocks.surrounding_tag_surrounds_before_and_after_blocks = true
  end
end

