require 'spec_helper'

describe Blocks::CollectionRenderer do
  let(:output_buffer) { [] }
  let(:runtime_args_settings) { [] }

  before do
    allow_any_instance_of(Hash).to receive(:runtime_args=) {|h, args| h[:runtime_args] = args }
    allow_any_instance_of(Hash).to receive(:runtime_args).and_return []
  end

  describe '#render' do
    it "should yield back the runtime_context if there is no collection present" do
      runtime_context = double(collection: nil)
      expect {|b| described_class.render(runtime_context, &b) }.to yield_with_args(runtime_context)
    end

    it "should loop over the collection and merge the item and index into the runtime_context" do
      collection = [:a, :b, :c, :d]
      runtime_context = Blocks::RuntimeContext.new
      runtime_context.collection = collection
      runtime_context.runtime_args = []
      described_class.render(runtime_context) do |extended_context|
        output_buffer << "Object: #{extended_context.collection_item}, Index: #{extended_context.collection_item_index}"
      end

      expect(output_buffer).to eq [
         "Object: a, Index: 0",
         "Object: b, Index: 1",
         "Object: c, Index: 2",
         "Object: d, Index: 3"
      ]
    end
  end
end