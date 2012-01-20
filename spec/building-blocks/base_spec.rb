require "spec_helper"

describe BuildingBlocks::Base do
  before :each do
    @builder = BuildingBlocks::Base.new({})
  end

  describe "defined? method" do
    it "should be able to determine if a block by a specific name is already defined" do
      @builder.defined?(:test_block).should be_false
      @builder.define :test_block do end
      @builder.defined?(:test_block).should be_true
      @builder.defined?("test_block").should be_true
    end
  end

  describe "define method" do
    it "should be able to define a new block" do
      block = Proc.new { |options| }

      @builder.define :test_block, :option1 => "value1", :option2 => "value2", &block

      test_block = @builder.blocks[:test_block]
      test_block.options[:option1].should eql("value1")
      test_block.options[:option2].should eql("value2")
      test_block.name.should eql(:test_block)
      test_block.block.should eql(block)
    end
    
    it "should not replace a defined block with another attempted definition" do
      block1 = Proc.new do |options| end
      @builder.define :test_block, :option1 => "value1", :option2 => "value2", &block1

      block2 = Proc.new do |options| end
      @builder.define :test_block, :option3 => "value3", :option4 => "value4", &block2

      test_block = @builder.blocks[:test_block]
       test_block.options[:option1].should eql("value1")
       test_block.options[:option2].should eql("value2")
       test_block.options[:option3].should be_nil
       test_block.options[:option4].should be_nil
       test_block.name.should eql(:test_block)
       test_block.block.should eql(block1)
    end
  end

  describe "replace method" do
    it "should be able to replace a defined block" do
      block1 = Proc.new do |options| end
      @builder.define :test_block, :option1 => "value1", :option2 => "value2", &block1

      block2 = Proc.new do |options| end
      @builder.replace :test_block, :option3 => "value3", :option4 => "value4", &block2

      test_block = @builder.blocks[:test_block]
      test_block.options[:option1].should be_nil
      test_block.options[:option2].should be_nil
      test_block.options[:option3].should eql("value3")
      test_block.options[:option4].should eql("value4")
      test_block.name.should eql(:test_block)
      test_block.block.should eql(block2)
    end
  end

  describe "use method" do
    it "should be able to use a defined block by its name" do
      @builder.expects(:render_block).with(:test_block, [], {})

      block = Proc.new do |options| end
      @builder.define :test_block, :option1 => "value1", :option2 => "value2", &block

      @builder.use :test_block
    end

    it "should be able to use a defined block by its name and pass in runtime arguments" do
      @builder.expects(:render_block).with(:test_block, ["value5"], {:option3 => "value3", :option4 => "value4"})

      block = Proc.new do |options| end
      @builder.define :test_block, :option1 => "value1", :option2 => "value2", &block

      @builder.use :test_block, "value5", :option3 => "value3", :option4 => "value4"
    end
  end
end