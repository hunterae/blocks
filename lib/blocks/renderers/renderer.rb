# frozen_string_literal: true

module Blocks
  class Renderer
    def self.render(builder, *args, &default_definition)
      options = args.extract_options!
      runtime_context = if !options.is_a?(RuntimeContext)
        RuntimeContext.build(builder, *args, options, &default_definition)
      else
        options
      end

      BlockWithHooksRenderer.render(runtime_context)
    end

    # TODO: this needs to be handled by a new renderer
    #  TODO: also get rid of BlockPlaceholder
    def self.deferred_render(builder, *args, &block)
      block_definition = builder.define(*args, &block)
      Blocks::BlockPlaceholder.new(block_definition)
    end
  end
end
