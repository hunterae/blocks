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
      expect(container).to eq hash.merge(block: block)
      expect(container.block).to eq block
      expect(container.name).to eq :test_block
      expect(container.anonymous).to eq false
    end

    # it "should be able to define a collection of blocks with names designated by a Proc" do
    #   hash = { a: 1 }.with_indifferent_access
    #   block = Proc.new {}
    #   containers = @builder.define(Proc.new {|i| "item#{i}"}, collection: [1,2,3,4], a: 1, &block)
    #   expect(containers).to be_a Array
    #   expect(containers.length).to eq 4
    #   expect(containers.map(&:name)).to eq ["item1", "item2", "item3", "item4"]
    #   expect(containers.map(&:block)).to eq [block, block, block, block]
    #   expect(containers.map(&:options_list).map(&:last)).to eq [hash, hash, hash, hash]
    #   expect(containers.map(&:anonymous)).to eq [false, false, false, false]
    # end

    it "should define a block's name anonymously when not specified" do
      container = @builder.define
      expect(container.name).to eq "block_1"
      expect(container.anonymous).to eq true
    end

    # it "should add options if a block if repeatedly defined" do
    #   hash1 = { a: 1 }.with_indifferent_access
    #   hash2 = { a: 2, b: 3 }.with_indifferent_access
    #   container1 = @builder.define :test_block, hash1
    #   container2 = @builder.define :test_block, hash2
    #
    #   expect(container1).to eq container2
    #   expect(container1.options_list.length).to eq 2
    #   expect(container1.options_list.first).to eq hash1
    #   expect(container1.options_list.last).to eq hash2
    #   expect(container1.merged_options).to eq hash1.reverse_merge(hash2)
    # end

    it "should only use the first definition provided for a block" do
      block1 = Proc.new {}
      block2 = Proc.new {}
      @builder.define :test_block, &block1
      container = @builder.define :test_block, &block2
      expect(container.block).not_to eq block2
      expect(container.block).to eq block1
    end
  end
end