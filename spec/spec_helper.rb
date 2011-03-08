require 'rubygems'
require 'bundler/setup'

require 'blocks' # and any other gems you need

RSpec.configure do |config|
  config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  # config.mock_with :rspec
end
