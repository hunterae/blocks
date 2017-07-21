$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
SimpleCov.start do
  add_filter "/spec"
  add_filter "/lib/blocks/experimental"
  add_group "Renderers", "/lib/blocks/renderers"
  add_group "Builders", "/lib/blocks/builders"
  add_group "Utilities", "/lib/blocks/utilities"
  add_group "Rails Extensions", "/lib/blocks/action_view_extensions"
end
# TODO: disable coverage unless running entire suite

begin
  require 'debugger'
rescue LoadError
end

begin
  require 'byebug'
rescue LoadError
end

begin
  require 'ruby-debug'
rescue LoadError
end

require 'rails/all'
require 'blocks'
require 'rspec'
require 'capybara/rspec'
require 'shoulda/matchers'

module Blocks
  class Application < Rails::Application
  end
end

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }

RSpec.configure do |config|
  config.after do
    Blocks.reset_config
  end

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run_when_matching :focus
  config.run_all_when_everything_filtered = true
end