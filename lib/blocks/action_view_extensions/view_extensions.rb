require 'action_view'

module Blocks
  module ViewExtensions
    def blocks
      @blocks ||= Blocks.builder_class.new(self)
    end

    def render_with_overrides(*args, &block)
      options = args.extract_options!.with_indifferent_access
      builder = options.delete(:builder)
      partial = args.first || options.delete(:partial) || options.delete(:template)
      if !builder
        builder = Blocks.builder_class.new(self, options)
      # elsif !!options.delete(:isolate_namespace)
      else
        builder.view = self
        # builder = builder.clone
        # TODO: figure out what to do here
      end
      builder.render_with_overrides(options.merge(partial: partial), &block)
    end
    alias_method :with_template, :render_with_overrides

  end
end

ActionView::Base.send :include, Blocks::ViewExtensions
