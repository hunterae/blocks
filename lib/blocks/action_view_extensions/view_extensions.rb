require 'action_view'

module Blocks
  module ViewExtensions
    def blocks
      @blocks ||= Blocks.builder_class.new(self)
    end

    def render_with_overrides(*args, &block)
      options = args.extract_options!.with_indifferent_access
      partial = options.delete(:partial) || options.delete(:template) || args.first
      if builder = options.delete(:builder)
        builder.view = self
        # builder = builder.clone
        # TODO: figure out what to do here
      else
        # TODO: options shouldn't have to be passed both here and to the render_with_overrides call below - need it to be just one place
        builder = Blocks.builder_class.new(self, options)
      end
      builder.render_with_overrides(options.merge(partial: partial), &block)
    end
    alias_method :with_template, :render_with_overrides

  end
end

ActionView::Base.send :include, Blocks::ViewExtensions
