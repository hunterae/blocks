$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
SimpleCov.start do
  add_filter "/spec"
  add_filter "/lib/blocks/experimental"
end

begin
  require 'debugger'
rescue LoadError
end

begin
  require 'byebug'
rescue LoadError
end

require 'rails/all'
require 'blocks'
require 'rspec'
require 'capybara/rspec'
# require 'rspec/rails'
require 'shoulda/matchers'

# Shoulda::Matchers.configure do |config|
#   config.integrate do |with|
#     with.test_framework :rspec
#   end
# end
# raise Shoulda::Matchers.methods.inspect
# Shoulda::Matchers.configure do |config|
#   config.integrate do |with|
#     # Choose a test framework:
#     with.test_framework :rspec
#
#     # Choose one or more libraries:
#     # with.library :active_record
#     # with.library :active_model
#     # with.library :action_controller
#     # Or, choose the following (which implies all of the above):
#     # with.library :rails
#   end
# end

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }

RSpec.configure do |config|
  config.after do
    Blocks.reset_config
  end

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end