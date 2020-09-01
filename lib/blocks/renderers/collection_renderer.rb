# frozen_string_literal: true

module Blocks
  class CollectionRenderer
    def self.render(runtime_context)
      collection = runtime_context.collection
      if collection
        original_collection_item = runtime_context.collection_item
        original_collection_item_index = runtime_context.collection_item_index
        original_runtime_args = runtime_context.runtime_args
        collection.each_with_index do |item, index|
          runtime_context.collection_item = item
          runtime_context.collection_item_index = index

          if Blocks.collection_item_passed_to_block_as_first_arg
            runtime_context.runtime_args = [item, *original_runtime_args]
          end

          yield runtime_context
        end
        runtime_context.collection_item = original_collection_item
        runtime_context.collection_item_index = original_collection_item_index
        runtime_context.runtime_args = original_runtime_args
      else
        yield runtime_context
      end
    end
  end
end