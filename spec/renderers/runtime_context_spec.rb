require 'spec_helper'

describe Blocks::RuntimeContext do
  let(:builder_options_set) { nil }
  let(:builder) { instance_double(Blocks::Builder) }
  let(:runtime_block) { Proc.new {} }
  let(:runtime_args) { [:a, :b, 3]}
  let(:block_name) { :some_block_name }
  let(:render_options) { { s: 1, t: 2, u: 3, defaults: { v: 4 } }}
  subject { described_class.build(builder, block_name, *runtime_args, render_options, &runtime_block) }

  before do
    allow(builder).to receive(:options_set).and_return(builder_options_set)
    allow(builder).to receive(:block_defined?).and_return(false)
  end
end