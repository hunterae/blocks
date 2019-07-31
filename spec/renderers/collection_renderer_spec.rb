require 'spec_helper'

describe Blocks::CollectionRenderer do
  let(:output_buffer) { [] }
  let(:runtime_args_settings) { [] }

  subject do
    Blocks::CollectionRenderer.new(double)
  end

  before do
    allow_any_instance_of(Hash).to receive(:runtime_args=) {|h, args| h[:runtime_args] = args }
    allow_any_instance_of(Hash).to receive(:runtime_args).and_return []
  end

  context '#render' do
    it "should yield back the runtime_context if there is no collection present" do
      runtime_context = double(collection: nil)
      expect {|b| subject.render(runtime_context, &b) }.to yield_with_args(runtime_context)
    end

    it "should loop over the collection and merge the item and index into the runtime_context" do
      collection = [:a, :b, :c, :d]
      runtime_context = { collection: collection, runtime_args: []}
      allow(runtime_context).to receive_messages(as: nil, collection: collection)
      subject.render(runtime_context) do |extended_context|
        expect(extended_context).not_to eql runtime_context
        output_buffer << "Args: #{extended_context[:runtime_args]}, Object: #{extended_context[:object]}, Index: #{extended_context[:current_index]}"
      end

      expect(output_buffer).to eq [
         "Args: [:a], Object: a, Index: 0",
         "Args: [:b], Object: b, Index: 1",
         "Args: [:c], Object: c, Index: 2",
         "Args: [:d], Object: d, Index: 3"
      ]
    end

    it "should be able to define an 'as' option to change the object name" do
      collection = [:a, :b, :c, :d]
      runtime_context = { collection: collection, runtime_args: []}
      allow(runtime_context).to receive_messages(as: :team, collection: collection)
      subject.render(runtime_context) do |extended_context|
        expect(extended_context).not_to eql runtime_context
        output_buffer << "Args: #{extended_context[:runtime_args]}, Team: #{extended_context[:team]}, Index: #{extended_context[:current_index]}"
      end

      expect(output_buffer).to eq [
         "Args: [:a], Team: a, Index: 0",
         "Args: [:b], Team: b, Index: 1",
         "Args: [:c], Team: c, Index: 2",
         "Args: [:d], Team: d, Index: 3"
      ]
    end

    it "prepend any existing runtime_args with the collection item" do
      collection = [:a, :b, :c, :d]
      allow_any_instance_of(Hash).to receive(:runtime_args).and_return [:arg1, 1, t: 1]
      runtime_context = { collection: collection, runtime_args: [:arg1, 1, t: 1]}
      allow(runtime_context).to receive_messages(as: nil, collection: collection)
      subject.render(runtime_context) do |extended_context|
        expect(extended_context).not_to eql runtime_context
        output_buffer << "Args: #{extended_context[:runtime_args]}, Object: #{extended_context[:object]}, Index: #{extended_context[:current_index]}"
      end

      expect(output_buffer).to eq [
         "Args: [:a, :arg1, 1, {:t=>1}], Object: a, Index: 0",
         "Args: [:b, :arg1, 1, {:t=>1}], Object: b, Index: 1",
         "Args: [:c, :arg1, 1, {:t=>1}], Object: c, Index: 2",
         "Args: [:d, :arg1, 1, {:t=>1}], Object: d, Index: 3"
      ]
    end
  end
end