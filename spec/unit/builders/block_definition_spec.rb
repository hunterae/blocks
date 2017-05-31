require 'spec_helper'

describe Blocks::BlockDefinition do
  let(:block_name) { :test_block }
  let(:block) { Proc.new {} }
  let(:block_options) { {} }
  subject { Blocks::BlockDefinition.new(block_name, block_options, &block) }

  context "Initialization" do
    let(:block_options) { { a: 1, runtime: { b: 2 }, defaults: { c: 3 }} }
    it "should extract and add the options" do
      expect(subject.standard_options).to eq "a" => 1, "block" => block
      expect(subject.runtime_options).to eq "b" => 2
      expect(subject.default_options).to eq "c" => 3
    end
    it "should use the first argument before the options as the name" do
      expect(subject.name).to eql block_name
    end
    it "should not require a name, options or a block" do
      expect { Blocks::BlockDefinition.new }.not_to raise_error
    end
  end

  context '#skip' do
    it "should mark the skip_content flag to true" do
      expect { subject.skip }.to change { subject.skip_content }.from(nil).to(true)
      expect(subject.skip_completely).to be false
    end
    it "should mark the skip_completely flag to true if specified" do
      expect { subject.skip(true) }.to change { subject.skip_completely }.from(nil).to(true)
      expect(subject.skip_content).to be true
    end
  end

  context '#skip_content?' do
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

  context '#skip_completely?' do
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

  context '#hooks_for' do
    it 'should call the corresponding hook method to fetch the hook array' do
      expect(subject).to receive :after_hooks
      subject.hooks_for(Blocks::HookDefinition::AFTER)

      expect(subject).to receive :before_all_hooks
      subject.hooks_for(Blocks::HookDefinition::BEFORE_ALL)
    end
  end

  Blocks::HookDefinition::HOOKS.each do |hook|
    context "##{hook}" do
      it "should add a HookDefinition to the end of the corresponding hook array" do
        expect { subject.send(hook, a: 1, runtime: { b: 2 }, defaults: { c: 3 })}.to change { subject.send("#{hook}_hooks").length }.from(0).to(1)
        hd = subject.send("#{hook}_hooks").last
        expect(hd.name).to eq "#{hook} #{subject.name} options"
        expect(hd.standard_options).to eq "a" => 1
        expect(hd.runtime_options).to eq "b" => 2
        expect(hd.default_options).to eq "c" => 3
      end
    end

    context "##{hook}_hooks" do
      it "should return the corresponding hook array" do
        subject.after a: 1
        expect(subject.after_hooks.length).to eq 1
      end
      it "should initialize and return an empty array if it does not exist yet" do
        expect(subject.after_hooks).to eq []
      end
    end
  end

  context '#to_s' do
    it "should report the render_strategy" do
      definition = Blocks::BlockDefinition.new(with: "some_block")
      expect(definition.to_s).to include "Renders with proxy block \"some_block\""

      definition = Blocks::BlockDefinition.new(partial: "some_partial")
      expect(definition.to_s).to include "Renders with partial \"some_partial\""

      definition = Blocks::BlockDefinition.new(&block)
      expect(definition.to_s).to match "Renders with block defined at.*spec/unit/builders/block_definition_spec.rb\", 5\]"
    end
    it "should detect the highest precedence render_strategy" do
      definition = Blocks::BlockDefinition.new(defaults: { with: "default_proxy" })
      expect(definition.to_s).to include "Renders with proxy block \"default_proxy\""

      definition = Blocks::BlockDefinition.new(defaults: { with: "default_proxy" }, with: "standard_proxy")
      expect(definition.to_s).to include "Renders with proxy block \"standard_proxy\""

      definition = Blocks::BlockDefinition.new(defaults: { with: "default_proxy" }, with: "standard_proxy", runtime: { with: "runtime_proxy" })
      expect(definition.to_s).to include "Renders with proxy block \"runtime_proxy\""
    end
  end

end