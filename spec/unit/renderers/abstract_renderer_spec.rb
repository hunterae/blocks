require 'spec_helper'

describe Blocks::AbstractRenderer do
  let(:builder) { Blocks::Builder.new(instance_double("ActionView::Base")) }
  let(:renderer) { Blocks::Renderer.new(builder) }
  subject { Blocks::AbstractRenderer.new(renderer) }

  context "Initialization" do
    xit "TODO"
  end

  context "Delegation" do
    Blocks::AbstractRenderer::RENDERERS.each do |field|
      field = field.to_s.demodulize.underscore.to_sym
      it { should delegate_method(field).to(:main_renderer) }
    end

    [:block_definitions, :view].each do |field|
      it { should delegate_method(field).to(:builder) }
    end

    [:with_output_buffer, :output_buffer].each do |field|
      it { should delegate_method(field).to(:view) }
    end
  end

  context '#render' do
    xit "TODO"
  end

  context '#capture' do
    xit "TODO"
  end
end