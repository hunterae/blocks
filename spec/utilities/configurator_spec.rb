require 'spec_helper'

describe Blocks::Configurator do
  context 'global defaults' do
    subject { Blocks }
    its(:builder_class) { is_expected.to eql Blocks::Builder }
    its(:renderer_class) { is_expected.to eql Blocks::Renderer }
    its(:global_options) { is_expected.to eql nil }
    its(:lookup_caller_location) { is_expected.to eql false }
    its(:track_caller) { is_expected.to eql false }
  end
  describe '#configure' do
    subject { Blocks }
    before do
      Blocks.configure do |config|
        config.builder_class = String
        config.renderer_class = String
        config.global_options = { a: 1 }
        config.lookup_caller_location = true
        config.track_caller = true
      end
    end

    its(:builder_class) { is_expected.to eql String }
    its(:renderer_class) { is_expected.to eql String }
    it 'should allow the global_options to be modified' do
      expect(Blocks.global_options).to match(a: 1)
    end
    its(:lookup_caller_location) { is_expected.to eql true }
    its(:track_caller) { is_expected.to eql true }

    context 'then calling #reset_config' do
      before do
        Blocks.reset_config
      end
      its(:builder_class) { is_expected.to eql Blocks::Builder }
      its(:renderer_class) { is_expected.to eql Blocks::Renderer }
      its(:global_options) { is_expected.to eql nil }
      its(:lookup_caller_location) { is_expected.to eql false }
      its(:track_caller) { is_expected.to eql false }
    end
  end


end
