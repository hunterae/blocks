require 'blocks/version'

module Jekyll
  class GemVersionTag < Liquid::Tag
    def render(context)
      Blocks::VERSION
    end
  end
end

Liquid::Template.register_tag('gem_version', Jekyll::GemVersionTag)