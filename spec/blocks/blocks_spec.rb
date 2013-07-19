require "spec_helper"

describe Blocks do
  it "should provide a util method to render a template" do
    view = stub
    options = stub
    partial = stub
    block = Proc.new { |options| }
    base_mock = mock
    base_mock.expects(:render_template).with(partial)
    Blocks::Base.expects(:new).with(view, options).returns(base_mock)

    Blocks.render_template(view, partial, options, &block)
  end

  it "should provide a setup method that can be called from an initializer" do
    Blocks.template_folder.should eql("blocks")
    Blocks.setup do |config|
      config.should eql(Blocks)
      config.template_folder = "shared"
    end
    Blocks.template_folder.should eql("shared")
  end
end