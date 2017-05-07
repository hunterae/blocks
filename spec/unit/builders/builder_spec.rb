require 'spec_helper'

describe Blocks::Builder do
  subject { Blocks::Builder.new(instance_double("ActionView::Base")) }

  context 'Initialization' do
    xit "should combine global options and init options into builder options"
    xit "should define a utility wrapper block :content_tag_wrapper"
    xit "should setup the block_definitions hash to initialize BlockDefinition objects when not present"
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
    xit "should instantiate a new Renderer instance"
    xit "should memoize the Renderer instance"
  end

  context '#block_defined?' do
    xit "should check if a block has previously been defined"
    xit "should not create the block if it is not present"
  end

  context '#define_each' do
    it "should be able to define a collection of blocks with names designated by a Proc" do
      hash = { a: 1 }.with_indifferent_access
      block = Proc.new {}
      block_definitions = subject.define_each([1,2,3,4], Proc.new {|i| "item#{i}"}, a: 1, &block)
      expect(block_definitions).to be_a Array
      expect(block_definitions.length).to eq 4
      expect(block_definitions.map(&:name)).to eq ["item1", "item2", "item3", "item4"]
      hash = hash.merge(block: block)
      expect(block_definitions.map(&:standard_options)).to eq [hash, hash, hash, hash]
      expect(block_definitions.map(&:anonymous)).to eq [false, false, false, false]
    end
  end

  context '#define' do
    it "should build a Blocks::BlockDefinition" do
      hash = { a: 1 }.with_indifferent_access
      block = Proc.new {}
      block_definition = subject.define(:test_block, hash, &block)
      expect(block_definition).to be_a Blocks::BlockDefinition
      expect(block_definition.standard_options).to eq hash.merge(block: block)
      expect(block_definition.name).to eq "test_block"
      expect(block_definition.anonymous).to eq false
    end

    it "should define a block's name anonymously when not specified" do
      block_definition = subject.define
      expect(block_definition.name).to eq "block_1"
      expect(block_definition.anonymous).to eq true
    end

    it "should add options if a block if repeatedly defined" do
      hash1 = { a: 1 }.with_indifferent_access
      hash2 = { a: 2, b: 3 }.with_indifferent_access
      block_definition1 = subject.define :test_block, hash1
      block_definition2 = subject.define :test_block, hash2

      expect(block_definition1.standard_options).to eq hash1.reverse_merge(hash2)
    end

    it "should only use the first definition provided for a block" do
      block1 = Proc.new {}
      block2 = Proc.new {}
      subject.define :test_block, &block1
      block_definition = subject.define :test_block, &block2
      expect(block_definition.standard_options[:block]).not_to eq block2
      expect(block_definition.standard_options[:block]).to eq block1
    end
  end

  context '#replace' do
    xit 'should completely replace an existing block definition'
    xit 'should not remember any previous options specified for the block definition'
    xit 'should not fail if a block is not defined'
  end

  context '#skip' do
    xit 'should call #skip on the block_definition'
    xit 'should allow a second option to be specified for whether a block should be completely skipped'
    xit 'should create the block if it has not been defined'
  end

  context '#skip_completely' do
    xit 'should call #skip with the completely flag set to true'
  end

  Blocks::HookDefinition::HOOKS.each do |hook|
    context "##{hook}" do
      xit "call #{hook} on the block definition"
      xit 'should create the block definition if has not been defined'
    end
  end

  # TODO: Move this method somewhere else
  context '#concatenating_merge' do
  end
end