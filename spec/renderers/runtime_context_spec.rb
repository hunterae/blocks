require 'spec_helper'

describe Blocks::RuntimeContext do
  let(:builder_options_set) { nil }
  let(:builder) { instance_double(Blocks::Builder) }
  let(:runtime_block) { Proc.new {} }
  let(:runtime_args) { [:a, :b, 3]}
  let(:block_name) { :some_block_name }
  let(:runtime_options) { { s: 1, t: 2, u: 3, defaults: { v: 4 } }}
  subject { described_class.build(builder, block_name, *runtime_args, runtime_options, &runtime_block) }

  before do
    allow(builder).to receive(:options_set).and_return(builder_options_set)
    allow(builder).to receive(:block_defined?).and_return(false)
  end

  its(:builder) { is_expected.to eql builder }
  its(:runtime_block) { is_expected.to eql runtime_block }
  its(:block_options_set) { is_expected.to be_nil }
  its(:block_name) { is_expected.to eql block_name }
  its(:runtime_args) { is_expected.to eql runtime_args }
  its(:render_item) { is_expected.to eql runtime_block }

  context 'Delegation' do
    xit "TODO"
  end

  context '#extend_from_definition' do
    xit "TODO"
  end
end