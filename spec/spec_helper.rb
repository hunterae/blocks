require 'rubygems'
require 'bundler/setup'

require 'blocks' # and any other gems you need

def print_hash(hash)
  hash.inject("") { |s, (k, v)| "#{s} #{k}: #{v}." }
end

RSpec.configure do |config|
  config.mock_with :mocha
  
  config.before :each do
    Blocks.template_folder = "blocks"
    Blocks.surrounding_tag_surrounds_before_and_after_blocks = true
    Blocks.use_partials = false
  end
end

