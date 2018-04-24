require 'spec_helper'

describe Blocks::AbstractRenderer do
  let(:builder) { Blocks::Builder.new(instance_double("ActionView::Base")) }
  let(:renderer) { Blocks::Renderer.new(builder) }
  subject { Blocks::AbstractRenderer.new(renderer) }

  context "Initialization" do
    it "should store the renderer as an attribute" do
      expect(subject.main_renderer).to eql renderer
    end
  end

  context "Delegation" do
    Blocks::AbstractRenderer::RENDERERS.each do |field|
      field = field.to_s.demodulize.underscore.to_sym
      it { should delegate_method(field).to(:main_renderer) }
    end
    it { should delegate_method(:builder).to(:main_renderer) }

    [:block_definitions, :view, :block_for, :hooks_for].each do |field|
      it { should delegate_method(field).to(:builder) }
    end

    [:with_output_buffer, :output_buffer].each do |field|
      it { should delegate_method(field).to(:view) }
    end
  end

  context '#render' do
    it 'should throw a NotImplementedError' do
      expect { subject.render }.to raise_error NotImplementedError
    end
  end

  context '#capture' do
    before do
      expect(subject).to receive(:output_buffer).and_return("")
      expect(subject).to receive(:with_output_buffer) do |&block|
        block.call
      end
    end

    context "when HAML is in play"
    context "when HAML is not in play" do
      before do
        allow(subject).to receive(:without_haml_interference) do |&block|
          block.call
        end
      end

      it "should use the view's capture method" do
        p = Proc.new {|a, b, c| "a: #{a}, b: #{b}, c: #{c}" }
        expect(subject.view).to receive(:capture).with(1, 2, 3) do |*args, &block|
          block.call(*args)
        end
        expect(subject.capture(1, 2, 3, &p)).to eql "a: 1, b: 2, c: 3"
      end

      it "should not pass more arguments than the block takes" do
        p = Proc.new {|a, b| "a: #{a}, b: #{b}" }
        expect(subject.view).to receive(:capture).with(1, 2) do |*args, &block|
          block.call(*args)
        end
        expect(subject.capture(1, 2, 3, &p)).to eql "a: 1, b: 2"
      end

      it "should be able to handle optional parameters" do
        p = Proc.new{|a, b=2, *c| "a: #{a}, b: #{b}, c: #{c}" }
        expect(subject.view).to receive(:capture).with(1,2,3,4,5,6,7,8) do |*args, &block|
          block.call(*args)
        end
        expect(subject.capture(1, 2, 3, 4, 5, 6, 7, 8, &p)).to eql "a: 1, b: 2, c: [3, 4, 5, 6, 7, 8]"
      end
    end
  end
end