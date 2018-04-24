require 'spec_helper'

describe Blocks::AdjacentBlocksRenderer do
  let(:block_name) { :some_block_name }
  let(:block_with_hooks_renderer) { instance_double(Blocks::BlockWithHooksRenderer) }
  let(:runtime_context) { instance_double(Blocks::RuntimeContext, block_name: block_name) }
  let(:renderer) { instance_double(Blocks::Renderer) }
  let(:output_buffer) { [] }
  subject do
    Blocks::AdjacentBlocksRenderer.new(renderer)
  end

  before do
    allow(subject).to receive(:output_buffer).and_return(output_buffer)
    allow(subject).to receive(:block_with_hooks_renderer).and_return(block_with_hooks_renderer)
  end

  context '#render' do
    it 'should not do anything if no hooks can be found' do
      expect(subject).to receive(:hooks_for).with(block_name, "SOME HOOK").and_return([])
      subject.render "SOME HOOK", runtime_context
      expect(output_buffer).to eql []
    end

    it 'should extend the runtime context with the hook definition and render it with the block_with_hooks_renderer' do
      extended_context = instance_double(Blocks::RuntimeContext)
      runtime_block = Proc.new {}
      hook_definition = instance_double(Blocks::HookDefinition, runtime_block: runtime_block)
      expect(subject).to receive(:hooks_for).with(block_name, "SOME HOOK").and_return([hook_definition])
      expect(runtime_context).to receive(:extend_from_definition).with(hook_definition) do |*, &content_block|
        expect(content_block).to eql runtime_block
        extended_context
      end
      expect(block_with_hooks_renderer).to receive(:render).with(extended_context).and_return "hook output"
      subject.render "SOME HOOK", runtime_context
      expect(output_buffer).to eql ["hook output"]
    end

    AFTER_HOOKS.each do |hook_name|
      it "should render #{hook_name} hooks in order" do
        extended_context1 = instance_double(Blocks::RuntimeContext)
        hook_definition1 = instance_double(Blocks::HookDefinition, runtime_block: nil)
        extended_context2 = instance_double(Blocks::RuntimeContext)
        hook_definition2 = instance_double(Blocks::HookDefinition, runtime_block: nil)
        expect(subject).to receive(:hooks_for).with(block_name, hook_name).and_return([hook_definition1, hook_definition2])
        expect(runtime_context).to receive(:extend_from_definition).with(hook_definition1).and_return extended_context1
        expect(runtime_context).to receive(:extend_from_definition).with(hook_definition2).and_return extended_context2
        expect(block_with_hooks_renderer).to receive(:render).with(extended_context1).and_return "hook output 1"
        expect(block_with_hooks_renderer).to receive(:render).with(extended_context2).and_return "hook output 2"
        subject.render hook_name, runtime_context
        expect(output_buffer).to eql ["hook output 1", "hook output 2"]
      end
    end

    BEFORE_HOOKS.each do |hook_name|
      it "should render #{hook_name} hooks in reverse order" do
        extended_context1 = instance_double(Blocks::RuntimeContext)
        hook_definition1 = instance_double(Blocks::HookDefinition, runtime_block: nil)
        extended_context2 = instance_double(Blocks::RuntimeContext)
        hook_definition2 = instance_double(Blocks::HookDefinition, runtime_block: nil)
        expect(subject).to receive(:hooks_for).with(block_name, hook_name).and_return([hook_definition1, hook_definition2])
        expect(runtime_context).to receive(:extend_from_definition).with(hook_definition1).and_return extended_context1
        expect(runtime_context).to receive(:extend_from_definition).with(hook_definition2).and_return extended_context2
        expect(block_with_hooks_renderer).to receive(:render).with(extended_context1).and_return "hook output 1"
        expect(block_with_hooks_renderer).to receive(:render).with(extended_context2).and_return "hook output 2"
        subject.render hook_name, runtime_context
        expect(output_buffer).to eql ["hook output 2", "hook output 1"]
      end
    end
  end
end