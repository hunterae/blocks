require 'spec_helper'

describe Blocks::BlockRenderer do
  let(:builder) { Blocks::Builder.new(instance_double("ActionView::Base")) }
  let(:renderer) { Blocks::Renderer.new(builder) }
  let(:output_buffer) { [] }
  let(:render_item) { nil }
  let(:runtime_block) { nil }
  let(:runtime_context) { double(render_item: render_item, runtime_args: [], runtime_block: runtime_block, output_buffer: output_buffer, to_hash: { a: 1, b: 2 }) }

  describe '#render' do
    it "should not output anything if the runtime_context does not have a render_item" do
      expect(runtime_context).not_to receive :capture
      expect(Blocks::PartialRenderer).not_to receive :render
      described_class.render(runtime_context)
      expect(output_buffer).to eq []
    end

    it "should not output anything if the render_item is something other than a string or a Proc" do
      allow(runtime_context).to receive(:render_item).and_return(:a_symbol)
      expect(runtime_context).not_to receive :capture
      expect(Blocks::PartialRenderer).not_to receive :render
      described_class.render(runtime_context)
      expect(output_buffer).to eq []
    end

    context "when the render_item is a string" do
      let(:render_item) { "some_partial" }

      it "should forward the request to the Blocks::PartialRenderer" do
        expect(Blocks::PartialRenderer).to receive(:render).and_return("Rendered #{render_item}")
        described_class.render(runtime_context)
        expect(output_buffer).to eq ["Rendered #{render_item}"]
      end
    end

    context "when the render_item is a Proc" do
      let(:render_item) { Proc.new {} }

      it 'should use #capture with the runtime_context and the Proc' do
        expect(runtime_context).to receive(:capture).with(runtime_context.to_hash, &render_item).and_return "Captured Block"
        described_class.render(runtime_context)
        expect(output_buffer).to eq ["Captured Block"]
      end

      it 'should pass any runtime_args from the RuntimeContext to the #capture call' do
        allow(runtime_context).to receive(:runtime_args).and_return [:a, :b, :c]
        expect(runtime_context).to receive(:capture).with(:a, :b, :c, runtime_context.to_hash, &render_item)
        described_class.render(runtime_context)
      end
    end

    context "when the render_item is a Method" do
      let(:runtime_block) { Proc.new {} }

      def method_with_no_args
      end

      def method_with_one_arg(arg1)
      end

      def method_with_two_args(arg1, arg2)
      end

      def method_with_indeterminate_args(*args)
      end

      def method_with_optional_args(arg1, arg2=nil)
      end

      before do
        expect(runtime_context).to receive(:capture) do |&block|
          block.call
        end
      end

      it "call the method with the runtime_block" do
        render_item = method(:method_with_no_args)
        expect(runtime_context).to receive(:render_item).and_return(render_item)
        expect(render_item).to receive(:call) do |&block|
          expect(block).to eql runtime_block
        end
        described_class.render(runtime_context)
      end

      it "should pass the runtime_context in as the last argument if the method can take enough arguments" do
        render_item = method(:method_with_one_arg)
        expect(runtime_context).to receive(:render_item).and_return(render_item)
        expect(render_item).to receive(:call).with(runtime_context.to_hash).and_return("Rendered")
        described_class.render(runtime_context)
        expect(output_buffer).to eql ["Rendered"]
      end

      it "should prioritize passing in arguments over the runtime context" do
        render_item = method(:method_with_one_arg)
        expect(runtime_context).to receive(:render_item).and_return(render_item)
        expect(render_item).to receive(:call).with(:a).and_return("Rendered")
        expect(runtime_context).to receive(:runtime_args).and_return [:a]
        described_class.render(runtime_context)
      end

      it "should only pass in the number of runtime arguments that a method takes" do
        render_item = method(:method_with_two_args)
        expect(runtime_context).to receive(:render_item).and_return(render_item)
        expect(render_item).to receive(:call).with(:a, :b).and_return("Rendered")
        expect(runtime_context).to receive(:runtime_args).and_return [:a, :b, :c, :d]
        described_class.render(runtime_context)
      end

      it "should pass in all the arguments and the runtime_context if the method has optional arguments" do
        render_item = method(:method_with_optional_args)
        expect(runtime_context).to receive(:render_item).and_return(render_item)
        expect(render_item).to receive(:call).with(:a, :b, :c, :d, runtime_context.to_hash).and_return("Rendered")
        expect(runtime_context).to receive(:runtime_args).and_return [:a, :b, :c, :d]
        described_class.render(runtime_context)
      end

      it "should pass in all the arguments and the runtime_context if the method can take an indeterminate number of arguments" do
        render_item = method(:method_with_indeterminate_args)
        expect(runtime_context).to receive(:render_item).and_return(render_item)
        expect(render_item).to receive(:call).with(:a, :b, :c, :d, runtime_context.to_hash).and_return("Rendered")
        expect(runtime_context).to receive(:runtime_args).and_return [:a, :b, :c, :d]
        described_class.render(runtime_context)
      end
    end
  end
end