require 'spec_helper'

describe Blocks::WrapperRenderer do
  let(:block) { Proc.new {} }
  let(:runtime_context) { double(to_hash: {}) }
  let(:output_buffer) { [] }

  before do
    allow(runtime_context).to receive(:merge).and_return(runtime_context)
    allow(runtime_context).to receive(:output_buffer).and_return(output_buffer)
    allow(runtime_context).to receive(:with_output_buffer) do |&block|
      block.call || "output"
    end
  end

  describe '#render' do
    it "should yield if there is no wrapper provided" do
      expect {|b| described_class.render(nil, :wrap_each, runtime_context, &b) }.to yield_with_no_args
      expect(output_buffer).to eq []
    end

    it "should capture the contents with the block, the runtime_args, and the runtime_context if the wrapper is a Proc" do
      expect(runtime_context).to receive(:runtime_args).and_return([:a, :b])
      expect(runtime_context).to receive(:capture) do |p, a, b, runtime_context, &block|
        expect(runtime_context).to eql runtime_context
        expect(a).to eql :a
        expect(b).to eql :b
        expect(p).to be_a Proc
        p.call
      end
      expect {|b| described_class.render(block, :wrap_each, runtime_context, &b) }.to yield_with_no_args
      expect(output_buffer).to eq ["output"]
    end

    it "should extend the runtime context to the wrapper and render it" do
      expect(runtime_context).to receive(:extend_from_definition) do |wrapper_name, options, &block|
        expect(wrapper_name).to eql :test_block
        expect(options).to eql(wrapper_type: :wrap_each)
        expect(block).to be_present
        extended_runtime_context = double
        expect(Blocks::BlockWithHooksRenderer).to receive(:render).with(extended_runtime_context).and_return(block.call)
        extended_runtime_context
      end
      described_class.render(:test_block, :wrap_each, runtime_context) do
        "hello"
      end
      expect(output_buffer).to eq ["hello"]
    end
  end
end