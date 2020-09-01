# frozen_string_literal: true

require 'action_view'

module Blocks
  module ViewExtensions
    def blocks
      @blocks ||= Blocks.builder_class.new(self)
    end

    def render_with_overrides(*args, &block)
      options = args.extract_options!
      partial = options.delete(:partial) || options.delete(:template) || args.first
      if builder = options.delete(:builder)
        builder.view = self
        # builder = builder.clone
        # TODO: figure out what to do here
      else
        # TODO: options shouldn't have to be passed both here and to the render call below - need it to be just one place
        builder = Blocks.builder_class.new(self, options)
      end
      builder.render(options.merge(partial: partial), &block)
    end

    # <b>DEPRECATED:</b> Please use <tt>render_with_overrides</tt> instead.
    def with_template(*args, &block)
      warn "[DEPRECATION] `with_template` is deprecated.  Please use `render_with_overrides` instead."
      render_with_overrides(*args, &block)
    end
  end
end

ActionView::Base.send :include, Blocks::ViewExtensions
