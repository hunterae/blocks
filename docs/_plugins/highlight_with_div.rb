# jekyll_inline_highlight
#
# A Liquid tag for inline syntax highlighting in Jekyll
#
# https://github.com/bdesham/inline_highlight
#
# Copyright (c) 2014-2015, Tom Preston-Werner and Benjamin Esham
# See README.md for full copyright information.

module Jekyll
	class HighlightWithDivBlock < Tags::HighlightBlock

		def add_code_tag(code)
			# code_attributes = [
      #     "class=\"language-#{@lang.to_s.tr("+", "-")}\"",
      #     "data-lang=\"#{@lang}\"",
      #   ].join(" ")
			code_attributes = "class=\"highlighter-rouge\""
      "<div #{code_attributes}><pre class=\"highlight\"><code>"\
      "#{code.chomp}</code></pre></div>"
		end
	end
end

Liquid::Template.register_tag('highlight', Jekyll::HighlightWithDivBlock)
