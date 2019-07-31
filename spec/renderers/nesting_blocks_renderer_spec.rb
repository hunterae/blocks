require 'spec_helper'

describe Blocks::NestingBlocksRenderer do
  let(:block_name) { :some_block_name }
  let(:block_with_hooks_renderer) { instance_double(Blocks::BlockWithHooksRenderer) }
  let(:runtime_context) { instance_double(Blocks::RuntimeContext, block_name: block_name) }
  let(:renderer) { instance_double(Blocks::Renderer) }
  let(:output_buffer) { [] }
  subject do
    Blocks::NestingBlocksRenderer.new(renderer)
  end

  before do
    allow(subject).to receive(:output_buffer).and_return(output_buffer)
    allow(subject).to receive(:block_with_hooks_renderer).and_return(block_with_hooks_renderer)
    allow(subject).to receive(:with_output_buffer) do |&block|
      block.call
    end
  end

  context '#render' do
    it 'should render nothing and yield if no hooks can be found' do
      expect(subject).to receive(:hooks_for).with(block_name, "SOME HOOK").and_return([])
      expect {|b| subject.render "SOME HOOK", runtime_context, &b }.to yield_with_no_args
      expect(output_buffer).to eql []
    end

    it 'should be able to nest content within a hook' do
      hook_definition = instance_double(Blocks::HookDefinition)
      expect(subject).to receive(:hooks_for).with(block_name, "SOME HOOK").and_return([hook_definition])
      expect(runtime_context).to receive(:extend_from_definition).with(hook_definition) do |*, &content_block|
        expect(content_block.call).to eql "CONTENT"
        Proc.new { "AROUND_BEGIN #{content_block.call} AROUND_END" }
      end
      expect(block_with_hooks_renderer).to receive(:render) do |extended_context|
        extended_context.call
      end
      subject.render "SOME HOOK", runtime_context do
        "CONTENT"
      end
      expect(output_buffer).to eql ["AROUND_BEGIN CONTENT AROUND_END"]
    end

    it 'should be able to nest multiple hooks' do
      content_block = Proc.new { "CONTENT" }
      expect(subject).to receive(:hooks_for).with(block_name, "SOME HOOK").and_return([
        instance_double(Blocks::HookDefinition),
        instance_double(Blocks::HookDefinition),
        instance_double(Blocks::HookDefinition)
      ])

      hook_number = 0
      expect(runtime_context).to receive(:extend_from_definition).exactly(3).times do |hook_definition, &inner_content|
        hook_number += 1
        Proc.new { |number|
          Proc.new {
            "HOOK_#{number}_BEGIN #{inner_content.call} HOOK_#{number}_END"
          }
        }.call(hook_number)
      end
      expect(block_with_hooks_renderer).to receive(:render).exactly(3).times do |extended_context|
        extended_context.call
      end

      subject.render "SOME HOOK", runtime_context do
        "CONTENT"
      end
      expect(output_buffer).to eql ["HOOK_3_BEGIN HOOK_2_BEGIN HOOK_1_BEGIN CONTENT HOOK_1_END HOOK_2_END HOOK_3_END"]
    end
  end
end