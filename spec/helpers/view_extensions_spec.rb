require 'spec_helper'

describe Blocks::ViewExtensions do
  subject { view }

  context '#blocks' do
    it "should return an instance of a Blocks.builder_class" do
      expect(Blocks).to receive(:builder_class).and_return(Blocks::Builder)
      expect(subject.blocks).to be_a Blocks::Builder
      expect(subject.blocks.view).to eql subject
    end

    it "should memoize the blocks instance" do
      expect(subject.blocks.object_id).to eql subject.blocks.object_id
    end
  end

  context '#with_template' do
    it 'should warn the coder and call #render_with_overrides' do
      runtime_block = Proc.new {}
      expect(subject).to receive(:warn)
      expect(subject).to receive(:render_with_overrides).with(:a, :b, :c) do |*, &block|
        expect(block).to eql runtime_block
      end
      subject.with_template(:a, :b, :c, &runtime_block)
    end
  end

  context '#render_with_overrides' do
    it "should pass the options and block along to the Blocks::Builder#render" do
      block = Proc.new {}
      expect_any_instance_of(Blocks::Builder).to receive(:render).with(partial: "my_partial", &block)
      subject.render_with_overrides(partial: "my_partial", &block)
    end

    it "should rewrite the template hash key to partial if specified" do
      block = Proc.new {}
      expect_any_instance_of(Blocks::Builder).to receive(:render).with(partial: "my_template", &block)
      subject.render_with_overrides(template: "my_template", &block)
    end

    it "should treat the first argument other than the hash as the partial if not otherwise specified" do
      block = Proc.new {}
      expect_any_instance_of(Blocks::Builder).to receive(:render).with(partial: "my_template", &block)
      subject.render_with_overrides("my_template", &block)
    end

    it "should allow a builder object to be specified and should set the view on the builder" do
      builder = double(:view= => true, render: "rendered")
      subject.render_with_overrides(partial: "my_partial", builder: builder)
    end
  end

end