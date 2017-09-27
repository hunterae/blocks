require 'spec_helper'

describe Blocks do
  it 'has a version number' do
    expect(Blocks::VERSION).not_to be nil
  end

  context '#configure' do
    xit "should allow builder_class to be configured"
    xit "should set a default builder_class"
    xit "should allow renderer_class to be configured"
    xit "should set a default builder_class"
    xit "should allow global_options to be configured"
    xit "should set a default global_options"
    xit "should allow lookup_caller_location to be configured"
    xit "should set a default lookup_caller_location"
  end

  context '.reset_config' do
    xit "should reset all the config optios to defaults"
  end
end
