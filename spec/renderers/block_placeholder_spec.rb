require 'spec_helper'

describe Blocks::BlockPlaceholder do
  context 'Initialization' do
    it 'should take a block definition and store it' do
      d = double
      placeholder = Blocks::BlockPlaceholder.new(d)
      expect(placeholder.block_definition).to eql d
    end
  end

  context '#to_s' do
    it "should output some text including the name of the block_definition" do
      d = double(name: "something")
      placeholder = Blocks::BlockPlaceholder.new(d)
      expect(placeholder.to_s).to eql "PLACEHOLDER_FOR_something "
    end
  end
end