require 'spec_helper'

describe Blocks::OptionsSet do
  let(:name) { "options_set_name" }
  let(:standard_options) { { a: 1 }}
  let(:runtime_options) { { b: 2 }}
  let(:default_options) { { c: 3 }}
  let(:block) { Proc.new {} }
  let(:options) { standard_options.merge(runtime: runtime_options).merge(defaults: default_options) }
  subject { described_class.new(name, options, &block) }

  its(:name) { is_expected.to eql name }
  its(:runtime_options) { is_expected.to be_a(Blocks::HashWithRenderStrategy) }
  its(:runtime_options) { is_expected.to match({ b: 2 })}
  its(:default_options) { is_expected.to be_a(Blocks::HashWithRenderStrategy) }
  its(:default_options) { is_expected.to match({ c: 3 })}
  its(:standard_options) { is_expected.to be_a(Blocks::HashWithRenderStrategy) }
  its(:standard_options) { is_expected.to match({ a: 1, block: block })}

  context 'Initialization' do
    it "should not require a name" do
      subject = described_class.new(options)
      expect(subject.name).to be_nil
    end

    it "should not require options" do
      subject = described_class.new(name)
      expect(subject).to match({})
    end

    # Passing a block to HashWithIndifferentAccess would
    #  be evaluated as a default proc for the Hash, which we don't want
    it "should not pass a block to the parent class" do
      expect(subject.default_proc).to be_nil
    end
  end

  context '#to_s' do
    xit 'TODO'
  end

  context '#inspect' do
    xit 'TODO'
  end

  context '#add_options' do
    xit 'TODO'
  end

  context '#reset' do
    before do
      subject.reset
    end
    its(:runtime_options) { is_expected.to be_a(Blocks::HashWithRenderStrategy) }
    its(:runtime_options) { is_expected.to match({}) }
    its(:default_options) { is_expected.to be_a(Blocks::HashWithRenderStrategy) }
    its(:default_options) { is_expected.to match({}) }
    its(:standard_options) { is_expected.to be_a(Blocks::HashWithRenderStrategy) }
    its(:standard_options) { is_expected.to match({}) }
  end

  context '#current_render_strategy_and_item' do
    it 'should return the runtime options render strategy and item if set' do
      expect(subject).to receive(:render_strategies_and_items).and_return([
        "RUNTIME", "STANDARD", "DEFAULTS"
      ])
      expect(subject.current_render_strategy_and_item).to eql "RUNTIME"
    end

    it 'should return the standard options render strategy and item if set and runtime is not' do
      expect(subject).to receive(:render_strategies_and_items).and_return([
        nil, "STANDARD", "DEFAULTS"
      ])
      expect(subject.current_render_strategy_and_item).to eql "STANDARD"
    end

    it 'should return the default options render strategy and item if set and runtime and standard are not' do
      expect(subject).to receive(:render_strategies_and_items).and_return([
        nil, nil, "DEFAULTS"
      ])
      expect(subject.current_render_strategy_and_item).to eql "DEFAULTS"
    end
  end

  context '#render_strategies_and_items' do
    it 'should return the #render_strategy_and_item for each option level' do
      expect(subject.runtime_options).to receive(:render_strategy_and_item).
        and_return("RUNTIME")
      expect(subject.standard_options).to receive(:render_strategy_and_item).
        and_return("STANDARD")
      expect(subject.default_options).to receive(:render_strategy_and_item).
        and_return("DEFAULTS")
      expect(subject.render_strategies_and_items).to eql [
        "RUNTIME",
        "STANDARD",
        "DEFAULTS"
      ]
    end
  end
end