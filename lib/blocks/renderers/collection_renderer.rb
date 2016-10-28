module Blocks
  class CollectionRenderer < AbstractRenderer
    def render(collection, *args, &block)
      if collection
        options = args.extract_options!
        collection.each do |item|
          yield *([item] + args + [options.merge(object: item)])
        end
      else
        yield *args
      end
    end
  end
end