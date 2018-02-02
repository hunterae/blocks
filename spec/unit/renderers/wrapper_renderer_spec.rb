require 'spec_helper'

describe Blocks::WrapperRenderer do
  let(:builder) { Blocks::Builder.new(instance_double("ActionView::Base")) }
  let(:renderer) { Blocks::Renderer.new(builder) }
  let(:block) { Proc.new {} }
  let(:runtime_context) { double }
  let(:output_buffer) { [] }
  subject do
    Blocks::WrapperRenderer.new(renderer)
  end

  before do
    allow(runtime_context).to receive(:merge).and_return(runtime_context)
    allow(subject).to receive(:output_buffer).and_return(output_buffer)
    allow(subject).to receive(:with_output_buffer) do |&block|
      block.call
      "output"
    end
  end

  context '#render' do
    it "should yield if there is no wrapper provided" do
      expect {|b| subject.render(nil, :wrap_each, runtime_context, &b) }.to yield_with_no_args
      expect(output_buffer).to eq []
    end

    it "should capture the contents with the block, the runtime_args, and the runtime_context if the wrapper is a Proc" do
      expect(runtime_context).to receive(:runtime_args).and_return([:a, :b])
      expect(subject).to receive(:capture) do |p, a, b, runtime_context, &block|
        expect(runtime_context).to eql runtime_context
        expect(a).to eql :a
        expect(b).to eql :b
        expect(p).to be_a Proc
        p.call
      end
      expect {|b| subject.render(block, runtime_context, &b) }.to yield_with_no_args
      expect(output_buffer).to eq ["output"]
    end

    it "should use the block_renderer to render the block if the wrapper is a defined block" do
      block_definition = double
      block_renderer = double
      extended_runtime_context = double
      o = nil

      expect(block_renderer).to receive(:render) do |p, extended_runtime_context|
        expect(extended_runtime_context).to eql extended_runtime_context
        expect(p).to be_a Proc
        p.call
        "result_from_block_renderer"
      end

      expect(subject).to receive(:block_for).with(:test_block).and_return block_definition
      expect(runtime_context).to receive(:extend_to_block_definition).with(block_definition).and_return extended_runtime_context
      expect(subject).to receive(:block_renderer).and_return(block_renderer)
      expect {|b| o = subject.render(:test_block, runtime_context, &b) }.to yield_with_no_args
      expect(o).to eq "result_from_block_renderer"
      expect(output_buffer).to eq []
    end

    it "should call the method on the builder if the builder responds to the wrapper" do
      expect(subject).to receive(:block_for).and_return nil
      expect(builder).to receive(:test_method) do |rc, &content_block|
        expect(rc).to eql runtime_context
        content_block.call
        "result_from_test_method"
      end

      expect {|b| subject.render(:test_method, runtime_context, &b) }.to yield_with_no_args
      expect(output_buffer).to eq ["result_from_test_method"]
    end

    it "should yield if the wrapper is not a proc or a method on the builder or a defined block" do
      expect {|b| subject.render(:test_block, runtime_context, &b) }.to yield_with_no_args
      expect(output_buffer).to eq []
    end
  end
end