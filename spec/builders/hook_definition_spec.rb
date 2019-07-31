require 'spec_helper'

describe Blocks::HookDefinition do
  let(:block_name) { :test_block }
  let(:block) { Proc.new }
  let(:block_options) { {} }
  let(:block_definition) { Blocks::BlockDefinition.new(block_name) }
  let(:additional_args) { ["a", "b", "c", block_options] }
  let(:hook_type) { Blocks::HookDefinition::AFTER_ALL }
  subject { Blocks::HookDefinition.new(block_definition, hook_type, *additional_args, &block) }

  context "Initialization" do
    xit "should set the block definition and hook type from the params"
    xit "should automatically generate a name based on the block definition"
    xit "should only pass the name, the additional arguments, and the block to the parent"
  end
end