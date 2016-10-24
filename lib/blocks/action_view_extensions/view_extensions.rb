require 'action_view'

module Blocks
  module ViewExtensions
    def blocks
      @blocks ||= Blocks.builder_class.new(self)
    end

    def render_with_overrides(template, options={}, builder=nil, &block)
      builder ||= options.delete(:builder)
      if builder
        builder.init_options = builder.init_options.merge(options)
        builder.view = self
      else
        builder = Blocks.builder_class.new(self, options)
      end
      builder.render_with_overrides(partial: template, &block)
    end
    alias_method :with_template, :render_with_overrides

  end
end

ActionView::Base.send :include, Blocks::ViewExtensions
