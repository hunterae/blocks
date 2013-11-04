require "spec_helper"

describe Blocks do
  it "should provide a setup method that can be called from an initializer" do
    Blocks.config.template_folder.should eql("blocks")
    Blocks.setup do |config|
      config.should be_a(Hashie::Mash)
      config.template_folder = "shared"
    end
    Blocks.config.template_folder.should eql("shared")
  end
end