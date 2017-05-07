require 'spec_helper'

describe Blocks::BlockDefinition do
  let(:block_name) { :test_block }
  let(:block) { Proc.new }
  let(:block_options) { {} }
  subject { Blocks::BlockDefinition.new(block_name, block_options, &block) }

  context "Initialization" do
    xit "should extract and add the options"
    xit "should merge the optional block as a key on the hash"
    xit "should use the first argument before the options as the name"
    xit "should not require a name, options or a block"
  end

  context '#skip' do
    xit "should mark the skip_content flag to true"
    xit "should mark the skip_completely flag to true if specified"
  end

  context '#anonymous?' do
    xit 'should return false if the flag has not been set'
    xit 'should return true or false depending on what the flag has been set to'
  end

  context '#skip_content?' do
    xit 'should return false if the flag has not been set'
    xit 'should return true or false depending on what the flag has been set to'
  end

  context '#skip_completely?' do
    xit 'should return false if the flag has not been set'
    xit 'should return true or false depending on what the flag has been set to'
  end

  context '#hooks_for' do
    xit 'should call the corresponding hook method to fetch the hook array'
  end

  Blocks::HookDefinition::HOOKS.each do |hook|
    context "##{hook}" do
      xit "should add a HookDefinition to the end of the corresponding hook array"
      xit "should not fail if the corresponding hook array has not been set"
    end

    context "##{hook}_hooks" do
      xit "should return the corresponding hook array"
    end
  end

  context '#to_s' do
    xit "should"
  end

end