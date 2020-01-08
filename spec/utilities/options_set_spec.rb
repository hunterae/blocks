require 'spec_helper'

describe Blocks::OptionsSet do
  let(:name) { "options_set_name" }
  let(:standard_options) { { a: 1 }}
  let(:default_options) { { c: 3 }}
  let(:block) { Proc.new {} }
  let(:options) { standard_options.merge(defaults: default_options) }
  subject { described_class.new(name, options, &block) }

  its(:name) { is_expected.to eql name }
  its(:default_options) { is_expected.to be_a(Blocks::HashWithRenderStrategy) }
  its(:default_options) { is_expected.to match({ c: 3 })}
  it { is_expected.to match({ a: 1, block: block })}
end