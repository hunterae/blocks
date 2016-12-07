module Blocks
  class BlockRenderer < AbstractRenderer
    def render(*args, &block)
      options = args.extract_options!
      output_buffer << if options[:partial]
        options = options.merge(block: block) if block_given?
        partial_renderer.render(options.delete(:partial), options)
      elsif block_given?
        capture_block(*args, options, &block)
      end
    end
  end
end