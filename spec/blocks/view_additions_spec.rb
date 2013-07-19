require "spec_helper"

describe Blocks::ViewAdditions do
  before(:each) do
    @view_class = Class.new
    @view = @view_class.new
    @view_class.send(:include, Blocks::ViewAdditions::ClassMethods)
  end

  describe "blocks method" do
    it "should pass the view as the only parameter to Blocks::Base initialization" do
      Blocks::Base.expects(:new).with {|view| view == @view}
      @view.blocks
    end

    it "should memoize the Blocks::Base instance for 'blocks' call" do
      Blocks::Base.expects(:new).once.with {|view| view == @view}.returns "something"
      @view.blocks.should eql "something"
      @view.blocks.should eql "something"
    end
  end
end