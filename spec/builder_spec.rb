require 'spec_helper'

describe Blocks::Builder do
  before do
    @builder = Blocks::Builder.new(instance_double("ActionView::Base"))
  end

  context '#define' do
    it "should create add a Block::Container to the block_containers hash" do
      @builder.define(:test_block, a: 1)
      expect(@builder.block_containers[:test_block].merged_options). to eq a: 1
    end
  end
end