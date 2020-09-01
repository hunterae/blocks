require 'spec_helper'

describe Blocks::BlockDefinition do
  let(:block_name) { :test_block }
  let(:block) { Proc.new {} }
  let(:block_options) { {} }
  subject { Blocks::BlockDefinition.new(block_name, block_options, &block) }

  context "Initialization" do
    let(:block_options) { { a: 1, defaults: { c: 3 }} }
    it "should extract and add the options" do
      expect(subject).to match :a => 1, :block => block
      expect(subject.default_options).to match :c => 3
    end
    it "should use the first argument before the options as the name" do
      expect(subject.name).to eql block_name
    end
    it "should not require a name, options or a block" do
      expect { Blocks::BlockDefinition.new }.not_to raise_error
    end
  end

  describe '#skip' do
    it "should mark the skip_content flag to true" do
      expect { subject.skip }.to change { subject.skip_content }.from(nil).to(true)
      expect(subject.skip_completely).to be false
    end
    it "should mark the skip_completely flag to true if specified" do
      expect { subject.skip(true) }.to change { subject.skip_completely }.from(nil).to(true)
      expect(subject.skip_content).to be true
    end
  end

  describe '#skip_content?' do
    it 'should return false if the flag has not been set' do
      expect(subject.skip_content?).to be false
    end
    it 'should return true or false depending on what the flag has been set to' do
      subject.skip_content = true
      expect(subject.skip_content?).to be true
      subject.skip_content = false
      expect(subject.skip_content?).to be false
    end
  end

  describe '#skip_completely?' do
    it 'should return false if the flag has not been set' do
      expect(subject.skip_completely?).to be false
    end
    it 'should return true or false depending on what the flag has been set to' do
      subject.skip_completely = true
      expect(subject.skip_completely?).to be true
      subject.skip_completely = false
      expect(subject.skip_completely?).to be false
    end
  end

  describe '#hooks_for' do
    it 'should return the hooks of a particular type when defined' do
      expect(subject.hooks_for(Blocks::HookDefinition::AFTER)).to eql nil
      hook = subject.after(a: 1)
      expect(subject.hooks_for(Blocks::HookDefinition::AFTER)).to match [hook]
    end

    it 'should initialize the hooks array when initialize_when_missing is specified as true' do
      expect(subject.hooks_for(Blocks::HookDefinition::AFTER)).to eql nil
      expect(subject.hooks_for(Blocks::HookDefinition::AFTER, initialize_when_missing: true)).to eql []
    end
  end

  Blocks::HookDefinition::HOOKS.each do |hook|
    describe "##{hook}" do
      it "should add a HookDefinition to the end of the corresponding hook array" do
        expect { subject.send(hook, a: 1)}.to change { subject.hooks_for(hook, initialize_when_missing: true).length }.from(0).to(1)
        hd = subject.hooks_for(hook).last
        expect(hd.name).to eq "#{hook} #{subject.name} options"
        expect(hd).to eq :a => 1
      end
    end
  end
end