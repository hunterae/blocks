require 'action_view'

module Blocks
  module ViewAdditions
    def blocks
      @blocks ||= Blocks::Builder.new(self)
    end

    def with_template(template, options={}, builder=nil, &block)
      original_init_options = nil
      builder = options.delete(:builder) if !builder
      if builder
        original_init_options = builder.init_options
        builder.init_options = builder.init_options.merge(options)
        builder.view = self
      else
        builder = Blocks::Builder.new(self, options)
      end

      builder.render_with_overrides(partial: template, &block).tap do
        builder.init_options = original_init_options if original_init_options
      end
    end
    alias_method :render_with_overrides, :with_template

  end
end

ActionView::Base.send :include, Blocks::ViewAdditions
