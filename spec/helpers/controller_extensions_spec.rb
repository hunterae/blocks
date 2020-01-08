require 'spec_helper'

describe Blocks::ControllerExtensions do
  subject { ActionController::Base.new }

  describe '#blocks' do
    it "should return an instance of a Blocks.builder_class" do
      view_context = double
      expect(subject).to receive(:view_context).and_return(view_context)
      expect(Blocks::Builder).to receive(:new).with(view_context).and_call_original
      expect(subject.blocks).to be_a Blocks::Builder
      expect(subject.blocks.view).to eql view_context
    end

    it "should memoize the blocks instance" do
      expect(subject.blocks.object_id).to eql subject.blocks.object_id
    end
  end
end