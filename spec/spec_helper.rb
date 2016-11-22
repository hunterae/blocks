$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'byebug'
require 'blocks'
require 'active_support/all'
require 'rspec'
require 'capybara/rspec'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }