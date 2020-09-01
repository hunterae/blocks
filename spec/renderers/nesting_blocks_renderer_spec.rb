require 'spec_helper'

describe Blocks::NestingBlocksRenderer do
  let(:runtime_context) { instance_double(Blocks::RuntimeContext) }
  let(:output_buffer) { [] }

  before do
    allow(runtime_context).to receive(:output_buffer).and_return(output_buffer)
    allow(runtime_context).to receive(:with_output_buffer) do |&block|
      block.call
    end
  end

  describe '#render' do
    it 'should render nothing and yield if no hooks can be found' do
      expect(runtime_context).to receive(:hooks_for).with("SOME HOOK").and_return([])
      expect {|b| described_class.render "SOME HOOK", runtime_context, &b }.to yield_with_no_args
      expect(output_buffer).to eql []
    end

    it 'should be able to nest content within a hook' do
      hook_definition = instance_double(Blocks::HookDefinition)
      expect(runtime_context).to receive(:hooks_for).with("SOME HOOK").and_return([hook_definition])
      expect(runtime_context).to receive(:extend_from_definition).with(hook_definition) do |*, &content_block|
        expect(content_block.call).to eql "CONTENT"
        Proc.new { "AROUND_BEGIN #{content_block.call} AROUND_END" }
      end
      expect(Blocks::BlockWithHooksRenderer).to receive(:render) do |extended_context|
        extended_context.call
      end
      described_class.render "SOME HOOK", runtime_context do
        "CONTENT"
      end
      expect(output_buffer).to eql ["AROUND_BEGIN CONTENT AROUND_END"]
    end

    it 'should be able to nest multiple hooks' do
      content_block = Proc.new { "CONTENT" }
      expect(runtime_context).to receive(:hooks_for).with("SOME HOOK").and_return([
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
      expect(Blocks::BlockWithHooksRenderer).to receive(:render).exactly(3).times do |extended_context|
        extended_context.call
      end

      described_class.render "SOME HOOK", runtime_context do
        "CONTENT"
      end
      expect(output_buffer).to eql ["HOOK_3_BEGIN HOOK_2_BEGIN HOOK_1_BEGIN CONTENT HOOK_1_END HOOK_2_END HOOK_3_END"]
    end
  end
end