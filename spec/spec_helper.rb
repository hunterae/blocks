require 'rubygems'
require 'bundler/setup'
require 'ruby-debug'

require 'blocks' # and any other gems you need

def print_hash(hash)
  hash.inject("") { |s, (k, v)| "#{s} #{k}: #{v}." }
end

RSpec.configure do |config|
  config.mock_with :mocha
  
  config.before :each do
    Blocks.setup do |config|
      config.partials_folder = "blocks"
      config.wrap_before_and_after_blocks = false
      config.use_partials = false
    end
  end
end

