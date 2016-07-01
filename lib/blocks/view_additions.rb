require 'action_view'

module Blocks
  module ViewAdditions
    def blocks
      @blocks ||= Blocks::Builder.new(self)
    end

    def with_template(template, options={}, &block)
      Blocks::Builder.new(self, options).render_template(template, &block)
    end
  end
end

ActionView::Base.send :include, Blocks::ViewAdditions
