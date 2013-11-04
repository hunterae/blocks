require "spec_helper"

describe Blocks do
  it "should provide a setup method that can be called from an initializer" do
    Blocks.config.partials_folder.should eql("blocks")
    Blocks.setup do |config|
      config.should be_a(Hashie::Mash)
      config.partials_folder = "shared"
    end
    Blocks.config.partials_folder.should eql("shared")
  end
end