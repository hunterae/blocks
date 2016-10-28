module Blocks
  class BlockRenderer < AbstractRenderer
    def render(*args, &block)
      options = args.extract_options!
      output_buffer << if options[:partial]
        partial_renderer.render(options.delete(:partial), options.merge(block: block))
      elsif block_given?
        capture_block(*args, options, &block)
      end
    end
  end
end