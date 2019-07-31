require 'spec_helper'

describe Blocks::Builder do
  let(:view) { Blocks::Builder.new(instance_double("ActionView::Base")) }
  subject { Blocks::Builder.new(view) }

  context 'Initialization' do
    it "should convert init options into an OptionsSet" do
      builder = Blocks::Builder.new(view, a: 1, runtime: { b: 2 }, defaults: { c: 3 })
      expect(builder.options_set).to be_a Blocks::OptionsSet
      expect(builder.standard_options).to eq :a => 1
      expect(builder.runtime_options).to eq :b => 2
      expect(builder.default_options).to eq :c => 3
    end
    it "should define a utility wrapper block Blocks::Builder::CONTENT_TAG_WRAPPER_BLOCK" do
      expect(subject.block_defined?(Blocks::Builder::CONTENT_TAG_WRAPPER_BLOCK)).to be true
    end
    it "should setup the block_definitions hash to initialize BlockDefinition objects when not present" do
      expect(subject.block_definitions).to be_a HashWithIndifferentAccess
      expect(subject.block_definitions[:test_block]).to be_a Blocks::BlockDefinition
    end
  end

  context 'Delegation' do
    [:render, :render_with_overrides, :deferred_render].each do |field|
      it { should delegate_method(field).to(:renderer) }
    end

    [:runtime_options, :standard_options, :default_options].each do |field|
      it { should delegate_method(field).to(:options_set) }
    end
  end

  context '#renderer' do
    it "should instantiate a new Renderer instance" do
      expect(subject.renderer).to be_a Blocks::Renderer
    end
    it "should memoize the Renderer instance" do
      expect(subject.renderer).to eql subject.renderer
    end
  end

  context '#block_for' do
    it 'should return nil if #block_defined? returns false' do
      expect(subject).to receive(:block_defined?).and_return false
      expect(subject.block_for(:some_block)).to be nil
    end
    it 'should return a block definition if #block_defined? returns false' do
      expect(subject).to receive(:block_defined?).and_return true
      expect(subject.block_for(:some_block)).to be_a Blocks::BlockDefinition
    end
  end

  context '#block_defined?' do
    it "should check if a block has previously been defined" do
      expect(subject.block_defined?(:test_block)).to be false
      subject.define :test_block, a: 1
      expect(subject.block_defined?(:test_block)).to be true
    end
    it "should not create the block if it is not present" do
      expect { subject.block_defined?(:test_block) }.to_not change { subject.block_definitions.length }
    end
  end

  context '#define' do
    it "should build a Blocks::BlockDefinition" do
      hash = { a: 1 }
      block = Proc.new {}
      block_definition = subject.define(:test_block, hash, &block)
      expect(block_definition).to be_a Blocks::BlockDefinition
      expect(block_definition.standard_options).to eq hash.merge(block: block)
      expect(block_definition.name).to eq "test_block"
    end

    it "should add options if a block if repeatedly defined" do
      hash1 = { a: 1 }
      hash2 = { a: 2, b: 3 }
      block_definition1 = subject.define :test_block, hash1
      block_definition2 = subject.define :test_block, hash2

      expect(block_definition1.standard_options).to eq hash1.reverse_merge(hash2)
    end

    it "should only use the first definition provided for a block" do
      block1 = Proc.new {}
      block2 = Proc.new {}
      subject.define :test_block, &block1
      block_definition = subject.define :test_block, &block2
      expect(block_definition.standard_options[:block].object_id).not_to eq block2.object_id
      expect(block_definition.standard_options[:block].object_id).to eq block1.object_id
    end

    it "should be able to define a block without a name" do
      block1 = Proc.new {}
      block_definition = subject.define a: 1, b: 2, &block1
      expect(block_definition.name).to eql "anonymous_block_1"
      expect(block_definition.standard_options).to eq :a => 1, :b => 2, :block => block1
    end
  end

  context '#replace' do
    it 'should completely replace an existing block definition' do
      subject.define :test_block, a: 1 do
        "hello"
      end
      subject.replace :test_block, b: 1, partial: "some_partial"
      test_block = subject.block_definitions[:test_block]
      expect(test_block.standard_options).to eql :b => 1, :partial => "some_partial"
    end
    it 'should not fail if a block is not defined' do
      subject.replace :test_block, a: 1, b: 2
      test_block = subject.block_definitions[:test_block]
      expect(test_block.standard_options).to eql :a => 1, :b => 2
    end
  end

  context '#skip' do
    it 'should call #skip on the block_definition' do
      block_definition = subject.define :test_block, a: 1 do
        "hello"
      end
      expect(block_definition).to receive(:skip).with false
      subject.skip :test_block
    end
    it 'should allow a second option to be specified for whether a block should be completely skipped' do
      block_definition = subject.define :test_block, a: 1
      expect(block_definition).to receive(:skip).with true
      subject.skip :test_block, true
    end

    it 'should create the block if it has not been defined' do
      expect { subject.skip :test_block }.to change { subject.block_definitions.length }.by 1
      expect(subject.block_defined?(:test_block)).to be true
    end
  end

  context '#skip_completely' do
    it 'should call #skip with the completely flag set to true' do
      expect(subject).to receive(:skip).with :test_block, true
      subject.skip_completely :test_block
    end
  end

  Blocks::HookDefinition::HOOKS.each do |hook|
    context "##{hook}" do
      it "call #{hook} on the block definition" do
        d = subject.define :test_block
        expect(d).to receive(hook).with(a: 1, b: 2)
        subject.send(hook, :test_block, a: 1, b: 2)
      end
      it 'should create the block definition if has not been defined' do
        expect(subject.block_defined?(:test_block)).to be false
        subject.after :test_block, partial: "test"
        expect(subject.block_defined?(:test_block)).to be true
      end
    end
  end

  # TODO: Move this method somewhere else
  context '#concatenating_merge' do
    it "should merge two hashes together" do
      h = subject.concatenating_merge({ a: 3 }, { b: 2, a: 1 })
      expect(h).to eq a: 1, b: 2
    end
    it "should be able to handle either one or both of the hashes being nil" do
      h = subject.concatenating_merge(nil, nil)
      expect(h).to eq({})
      h = subject.concatenating_merge(nil, { b: 2 })
      expect(h).to eq b: 2
      h = subject.concatenating_merge({ a: 1 }, nil)
      expect(h).to eq a: 1
    end
    it "should combine any hash values that are strings whose keys match" do
      h = subject.concatenating_merge({a: 1, class: "hello"}, { b: 2, class: "world" })
      expect(h).to eq a: 1, b: 2, class: "hello world"
    end

    it "should treat strings and symbols for keys as the same" do
      h = subject.concatenating_merge({a: 1, class: "hello" }, { "a" => 2, "class" => "world" })
      expect(h).to eq a: 2, class: "hello world"
    end
  end

  context '#hooks_for' do
    it "should return all hooks of a given type for a given block" do
      hook1 = subject.around :a, with: :something
      hook2 = subject.around :a, with: :something2
      hook3 = subject.before :a, with: :something3
      hook4 = subject.prepend :a, with: :something4
      expect(subject.hooks_for(:a, :around)).to eql [hook1, hook2]
      expect(subject.hooks_for(:a, :before)).to eql [hook3]
      expect(subject.hooks_for(:a, :prepend)).to eql [hook4]
    end

    it "should return an empty array and not define a block if it is not already defined" do
      expect(subject.hooks_for(:a, :around)).to eql []
      expect(subject.block_defined?(:a)).to be false
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