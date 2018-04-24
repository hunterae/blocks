# Complete hack to get around issues with Haml
#  Haml does some hacking to ActionView's with_output_buffer and
#  output_buffer. In doing so, they make certain assumptions about
#  the layout and the view template. (See:
#  https://github.com/haml/haml/blob/master/lib/haml/helpers/action_view_mods.rb#L11,
#  and https://github.com/haml/haml/blob/master/lib/haml/helpers.rb#L389)
#  The Blocks gem doesn't capture
#  blocks immediately but rather stores them for later capturing.
#  This can produce an issue if a block that is stored was defined in Haml
#  but the Layout is in ERB. Haml will think that any blocks it
#  captures while rendering the layout will be in ERB format. However,
#  the block would need to be captured in Haml using a Haml buffer.
#  This workaround accomplishes that.
module Blocks
  module HamlCapture
    def capture(*)
      old_haml_buffer = view.instance_variable_get(:@haml_buffer)
      if old_haml_buffer
        was_active = old_haml_buffer.active?
        old_haml_buffer.active = false
      else
        haml_buffer = Haml::Buffer.new(nil, Haml::Options.new.for_buffer)
        haml_buffer.active = false
        view.instance_variable_set(:@haml_buffer, haml_buffer)
      end
      super
    ensure
      old_haml_buffer.active = was_active if old_haml_buffer
      view.instance_variable_set(:@haml_buffer, old_haml_buffer)
    end
  end
end