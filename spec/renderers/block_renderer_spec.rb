require 'spec_helper'

describe Blocks::BlockRenderer do
  # class BuilderWithMethods < Blocks::Builder
  #
  # end

  let(:builder) { Blocks::Builder.new(instance_double("ActionView::Base")) }
  let(:renderer) { Blocks::Renderer.new(builder) }
  let(:output_buffer) { [] }
  let(:render_item) { nil }
  let(:runtime_block) { nil }
  let(:runtime_context) { double(render_item: render_item, runtime_args: [], runtime_block: runtime_block) }
  let(:partial_renderer) { double }

  subject do
    Blocks::BlockRenderer.new(double).tap do |r|
      allow(r).to receive(:output_buffer).and_return output_buffer
      allow(r).to receive(:partial_renderer).and_return partial_renderer
    end
  end

  context '#render' do
    it "should not output anything if the runtime_context does not have a render_item" do
      runtime_context = double(render_item: :a_symbol_render_item )
      expect(subject).not_to receive :capture
      expect(partial_renderer).not_to receive :render
      subject.render(runtime_context)
      expect(output_buffer).to eq []
    end

    it "should not output anything if the render_item is something other than a string or a Proc" do
      expect(subject).not_to receive :capture
      expect(partial_renderer).not_to receive :render
      subject.render(runtime_context)
      expect(output_buffer).to eq []
    end

    context "when the render_item is a string" do
      let(:render_item) { "some_partial" }

      it "should pass the render_item to the partial_renderer" do
        expect(partial_renderer).to receive(:render).with(render_item, runtime_context)
        subject.render(runtime_context)
      end

      it "should append the output to the output_buffer" do
        expect(partial_renderer).to receive(:render).and_return("Rendered #{render_item}")
        subject.render(runtime_context)
        expect(output_buffer).to eq ["Rendered #{render_item}"]
      end
    end

    context "when the render_item is a Proc" do
      let(:render_item) { Proc.new {} }

      it 'should use #capture with the runtime_context and the Proc' do
        expect(subject).to receive(:capture).with(runtime_context, &render_item)
        subject.render(runtime_context)
      end

      it 'should append the output to the output_buffer' do
        expect(subject).to receive(:capture).and_return "Captured Block"
        subject.render(runtime_context)
        expect(output_buffer).to eq ["Captured Block"]
      end

      it 'should pass any runtime_args from the RuntimeContext to the #capture call' do
        allow(runtime_context).to receive(:runtime_args).and_return [:a, :b, :c]
        expect(subject).to receive(:capture).with(:a, :b, :c, runtime_context, &render_item)
        subject.render(runtime_context)
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
        expect(subject).to receive(:capture) do |&block|
          block.call
        end
      end

      it "call the method with the runtime_block" do
        render_item = method(:method_with_no_args)
        expect(runtime_context).to receive(:render_item).and_return(render_item)
        expect(render_item).to receive(:call) do |&block|
          expect(block).to eql runtime_block
        end
        subject.render(runtime_context)
      end

      it "should pass the runtime_context in as the last argument if the method can take enough arguments" do
        render_item = method(:method_with_one_arg)
        expect(runtime_context).to receive(:render_item).and_return(render_item)
        expect(render_item).to receive(:call).with(runtime_context).and_return("Rendered")
        subject.render(runtime_context)
        expect(output_buffer).to eql ["Rendered"]
      end

      it "should prioritize passing in arguments over the runtime context" do
        render_item = method(:method_with_one_arg)
        expect(runtime_context).to receive(:render_item).and_return(render_item)
        expect(render_item).to receive(:call).with(:a).and_return("Rendered")
        expect(runtime_context).to receive(:runtime_args).and_return [:a]
        subject.render(runtime_context)
      end

      it "should only pass in the number of runtime arguments that a method takes" do
        render_item = method(:method_with_two_args)
        expect(runtime_context).to receive(:render_item).and_return(render_item)
        expect(render_item).to receive(:call).with(:a, :b).and_return("Rendered")
        expect(runtime_context).to receive(:runtime_args).and_return [:a, :b, :c, :d]
        subject.render(runtime_context)
      end

      it "should pass in all the arguments and the runtime_context if the method has optional arguments" do
        render_item = method(:method_with_optional_args)
        expect(runtime_context).to receive(:render_item).and_return(render_item)
        expect(render_item).to receive(:call).with(:a, :b, :c, :d, runtime_context).and_return("Rendered")
        expect(runtime_context).to receive(:runtime_args).and_return [:a, :b, :c, :d]
        subject.render(runtime_context)
      end

      it "should pass in all the arguments and the runtime_context if the method can take an indeterminate number of arguments" do
        render_item = method(:method_with_indeterminate_args)
        expect(runtime_context).to receive(:render_item).and_return(render_item)
        expect(render_item).to receive(:call).with(:a, :b, :c, :d, runtime_context).and_return("Rendered")
        expect(runtime_context).to receive(:runtime_args).and_return [:a, :b, :c, :d]
        subject.render(runtime_context)
      end
    end
  end
end