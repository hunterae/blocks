require 'spec_helper'

describe Blocks::Builder do
  before do
    @builder = Blocks::Builder.new(instance_double("ActionView::Base"))
  end

  context '#define' do
    it "should build a Blocks::BlockContainer" do
      hash = { a: 1 }.with_indifferent_access
      block = Proc.new {}
      container = @builder.define(:test_block, hash, &block)
      expect(container).to be_a Blocks::BlockContainer
      expect(container.options_list.last).to eq hash
      expect(container.block).to eq block
      expect(container.name).to eq :test_block
      expect(container.anonymous).to eq false
    end

    it "should be able to define a collection of blocks with names designated by a Proc" do
      hash = { a: 1 }.with_indifferent_access
      block = Proc.new {}
      containers = @builder.define(Proc.new {|i| "item#{i}"}, collection: [1,2,3,4], a: 1, &block)
      expect(containers).to be_a Array
      expect(containers.length).to eq 4
      expect(containers.map(&:name)).to eq ["item1", "item2", "item3", "item4"]
      expect(containers.map(&:block)).to eq [block, block, block, block]
      expect(containers.map(&:options_list).map(&:last)).to eq [hash, hash, hash, hash]
      expect(containers.map(&:anonymous)).to eq [false, false, false, false]
    end

    it "should define a block's name anonymously when not specified" do
      container = @builder.define
      expect(container.name).to eq "block_1"
      expect(container.anonymous).to eq true
    end

    it "should define a the names of a collection of items anonymously when not specified" do
      containers = @builder.define collection: [1, 2]
      expect(containers.map(&:name)).to eq ["block_1", "block_2"]
      expect(containers.map(&:anonymous)).to eq [true, true]
    end
  end
end