require "spec_helper"

describe BuildingBlocks::ViewAdditions do
  before(:each) do
    @view_class = Class.new
    @view = @view_class.new
    @view_class.send(:include, BuildingBlocks::ViewAdditions::ClassMethods)
  end

  describe "blocks method" do
    it "should pass the view as the only parameter to BuildingBlocks::Base initialization" do
      BuildingBlocks::Base.expects(:new).with {|view| view == @view}
      @view.blocks
    end

    it "should memoize the BuildingBlocks::Base instance for 'blocks' call" do
      BuildingBlocks::Base.expects(:new).once.with {|view| view == @view}.returns "something"
      @view.blocks.should eql "something"
      @view.blocks.should eql "something"
    end

    it "should be aliased as bb, buildingblocks, and building_blocks" do
      BuildingBlocks::Base.expects(:new).with {|view| view == @view}
      @view.bb

      BuildingBlocks::Base.expects(:new).with {|view| view == @view}
      @view.buildingblocks

      BuildingBlocks::Base.expects(:new).with {|view| view == @view}
      @view.building_blocks
    end
  end
end