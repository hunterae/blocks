require 'spec_helper'

describe Blocks::BlockRenderer do
  let(:builder) { Blocks::Builder.new(instance_double("ActionView::Base")) }
  let(:renderer) { Blocks::Renderer.new(builder) }
  let(:output_buffer) { [] }
  let(:render_item) { nil }
  let(:runtime_context) { double(render_item: render_item, runtime_args: []) }
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

      it 'should pass any extra args to the render call to the #capture call' do
        expect(subject).to receive(:capture).with(:d, :e, :f, runtime_context, &render_item)
        subject.render(:d, :e, :f, runtime_context)
      end

      it 'should append runtime_args to the extra args to the render call' do
        allow(runtime_context).to receive(:runtime_args).and_return [:a, :b, :c]
        expect(subject).to receive(:capture).with(:d, :e, :f, :a, :b, :c, runtime_context, &render_item)
        subject.render(:d, :e, :f, runtime_context)
      end
    end
  end
end