require 'spec_helper'

describe Blocks::Renderer do
  let(:view) { ActionView::Base.new }
  let(:builder) { Blocks::Builder.new(view) }
  let(:block_with_hooks_renderer) { builder.block_with_hooks_renderer }

  subject { Blocks::Renderer.new(builder) }

  context 'Initialization' do
    xit "TODO"
  end

  context '#render' do
    it "should render nothing when passed no arguments" do
      expect(subject.render).to eq ""
    end

    it "should render nothing when the block doesn't exist" do
      expect(subject.render(:test_block)).to eq ""
    end

    it "should render the specified block by name" do
      builder.define :test_block, &Proc.new { "Hello" }
      expect(subject.render(:test_block)).to eq "Hello"
    end

    it "should not care whether the block name is a String or Symbol" do
      builder.define :test_block, &Proc.new { "Hello" }
      expect(subject.render("test_block")).to eq "Hello"
    end

    it "should pass off render control to the block_with_hooks_renderer" do
      block = Proc.new {}
      block_with_hooks_renderer = double
      expect(block_with_hooks_renderer).to receive(:render).with(:test_block, 1, 2, &block).and_return("Rendered")
      expect(subject).to receive(:block_with_hooks_renderer).and_return(block_with_hooks_renderer)
      expect(subject.render(:test_block, 1, 2, &block)).to eq "Rendered"
    end
  end

  context '#render_with_overrides' do
    xit "TODO"
  end

  context '#deferred_render' do
    xit "TODO"
  end
end