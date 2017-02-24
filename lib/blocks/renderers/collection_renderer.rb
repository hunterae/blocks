module Blocks
  class CollectionRenderer < AbstractRenderer
    def render(runtime_context)
      collection = runtime_context.collection
      if collection
        object_name = runtime_context.as || :object
        collection.each_with_index do |item, index|
          item_runtime_context = runtime_context.merge(object_name => item, current_index: index)
          item_runtime_context.runtime_args = [item] + item_runtime_context.runtime_args
          yield item_runtime_context
        end
      else
        yield runtime_context
      end
    end
  end
end