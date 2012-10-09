require "spec_helper"

describe BuildingBlocks do
  it "should provide a util method to render a template" do
    view = stub
    options = stub
    partial = stub
    block = Proc.new { |options| }
    base_mock = mock
    base_mock.expects(:render_template).with(partial)
    BuildingBlocks::Base.expects(:new).with(view, options).returns(base_mock)

    BuildingBlocks.render_template(view, partial, options, &block)
  end

  it "should provide a setup method that can be called from an initializer" do
    BuildingBlocks.template_folder.should eql("blocks")
    BuildingBlocks.setup do |config|
      config.should eql(BuildingBlocks)
      config.template_folder = "shared"
    end
    BuildingBlocks.template_folder.should eql("shared")
  end
end