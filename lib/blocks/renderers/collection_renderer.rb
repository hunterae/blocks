module Blocks
  class CollectionRenderer < AbstractRenderer
    def render(collection, *args, &block)
      if collection
        options = args.extract_options!
        object_name = options.delete(:as) || :object
        collection.each_with_index do |item, index|
          yield *([item] + args + [options.merge(object_name => item, current_index: index)])
        end
      else
        yield *args
      end
    end
  end
end