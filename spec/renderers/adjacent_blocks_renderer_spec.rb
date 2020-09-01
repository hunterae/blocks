require 'spec_helper'

describe Blocks::AdjacentBlocksRenderer do
  let(:runtime_context) { instance_double(Blocks::RuntimeContext) }
  let(:output_buffer) { [] }

  before do
    allow(runtime_context).to receive(:output_buffer).and_return(output_buffer)
    allow(Blocks::BlockWithHooksRenderer).to receive(:render)
  end

  describe '.render' do
    it 'should not do anything if no hooks can be found' do
      expect(runtime_context).to receive(:hooks_for).with("SOME HOOK").and_return([])
      described_class.render "SOME HOOK", runtime_context
      expect(output_buffer).to eql []
    end

    it 'should extend the runtime context with the hook definition and render it with the BlockWithHooksRenderer' do
      extended_context = instance_double(Blocks::RuntimeContext)
      runtime_block = Proc.new {}
      hook_definition = instance_double(Blocks::HookDefinition, runtime_block: runtime_block)
      expect(runtime_context).to receive(:hooks_for).with("SOME HOOK").and_return([hook_definition])
      expect(runtime_context).to receive(:extend_from_definition).with(hook_definition) do |*, &content_block|
        expect(content_block).to eql runtime_block
        extended_context
      end
      expect(Blocks::BlockWithHooksRenderer).to receive(:render).with(extended_context).and_return "hook output"
      described_class.render "SOME HOOK", runtime_context
      expect(output_buffer).to eql ["hook output"]
    end

    AFTER_HOOKS.each do |hook_name|
      it "should render #{hook_name} hooks in order" do
        extended_context1 = instance_double(Blocks::RuntimeContext)
        hook_definition1 = instance_double(Blocks::HookDefinition, runtime_block: nil)
        extended_context2 = instance_double(Blocks::RuntimeContext)
        hook_definition2 = instance_double(Blocks::HookDefinition, runtime_block: nil)
        expect(runtime_context).to receive(:hooks_for).with(hook_name).and_return([hook_definition1, hook_definition2])
        expect(runtime_context).to receive(:extend_from_definition).with(hook_definition1).and_return extended_context1
        expect(runtime_context).to receive(:extend_from_definition).with(hook_definition2).and_return extended_context2
        expect(Blocks::BlockWithHooksRenderer).to receive(:render).with(extended_context1).and_return "hook output 1"
        expect(Blocks::BlockWithHooksRenderer).to receive(:render).with(extended_context2).and_return "hook output 2"
        described_class.render hook_name, runtime_context
        expect(output_buffer).to eql ["hook output 1", "hook output 2"]
      end
    end

    BEFORE_HOOKS.each do |hook_name|
      it "should render #{hook_name} hooks in reverse order" do
        extended_context1 = instance_double(Blocks::RuntimeContext)
        hook_definition1 = instance_double(Blocks::HookDefinition, runtime_block: nil)
        extended_context2 = instance_double(Blocks::RuntimeContext)
        hook_definition2 = instance_double(Blocks::HookDefinition, runtime_block: nil)
        expect(runtime_context).to receive(:hooks_for).with(hook_name).and_return([hook_definition1, hook_definition2])
        expect(runtime_context).to receive(:extend_from_definition).with(hook_definition1).and_return extended_context1
        expect(runtime_context).to receive(:extend_from_definition).with(hook_definition2).and_return extended_context2
        expect(Blocks::BlockWithHooksRenderer).to receive(:render).with(extended_context1).and_return "hook output 1"
        expect(Blocks::BlockWithHooksRenderer).to receive(:render).with(extended_context2).and_return "hook output 2"
        described_class.render hook_name, runtime_context
        expect(output_buffer).to eql ["hook output 2", "hook output 1"]
      end
    end
  end
end