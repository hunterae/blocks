# frozen_string_literal: true

module Blocks
  class Renderer
    attr_accessor :builder
    delegate :render, to: :block_with_hooks_renderer
    delegate :view, to: :builder
    delegate :with_output_buffer, :output_buffer, to: :view

    def initialize(builder)
      self.builder = builder
    end

    # <b>DEPRECATED:</b> Please use <tt>render</tt> instead.
    def render_with_overrides(*args, &block)
      warn "[DEPRECATION] `render_with_overrides` is deprecated.  Please use `render` instead."
      render(*args, &block)
    end

    # TODO: this needs to be handled by a new renderer
    #  TODO: also get rid of BlockPlaceholder
    def deferred_render(*args, &block)
      block_definition = builder.define(*args, &block)
      Blocks::BlockPlaceholder.new(block_definition)
    end

    AbstractRenderer::RENDERERS.each do |klass|
      name = klass.to_s.demodulize.underscore.to_sym
      define_method name do
        klass.new(self)
      end
    end
  end
end
