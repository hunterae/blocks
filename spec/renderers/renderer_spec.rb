require 'spec_helper'

describe Blocks::Renderer do
  context 'Initialization' do
    xit "TODO"
  end

  describe '#render' do
    it "should render nothing when passed no arguments" do
      expect(described_class.render(builder)).to eq ""
    end

    it "should render nothing when the block doesn't exist" do
      expect(described_class.render(builder, :test_block)).to eq ""
    end

    it "should render the specified block by name" do
      builder.define :test_block, &Proc.new { "Hello" }
      expect(described_class.render(builder, :test_block)).to eq "Hello"
    end

    it "should not care whether the block name is a String or Symbol" do
      builder.define :test_block, &Proc.new { "Hello" }
      expect(described_class.render(builder, "test_block")).to eq "Hello"
    end

    it "should pass off render control to the block_with_hooks_renderer" do
      block = Proc.new {}
      runtime_context = double
      expect(Blocks::RuntimeContext).to receive(:build).with(builder, :test_block, 1, 2, a: 1, &block).and_return(runtime_context)
      expect(Blocks::BlockWithHooksRenderer).to receive(:render).with(runtime_context).and_return("Rendered")
      expect(described_class.render(builder, :test_block, 1, 2, a: 1, &block)).to eq "Rendered"
    end
  end

  describe '#deferred_render' do
    it "should define the block and return a Blocks::BlockPlaceholder" do
      block_definition = instance_double(Blocks::BlockDefinition)
      expect(builder).to receive(:define).with(:a, :b, :c) do |*args, &block|
        expect(block).to be_present
        block_definition
      end
      expect(Blocks::BlockPlaceholder).to receive(:new).with(block_definition)
      described_class.deferred_render(builder, :a, :b, :c) do
      end
    end
  end
end