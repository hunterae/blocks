# frozen_string_literal: true

module Blocks
  module LegacyBuilders
    CONTENT_TAG_WRAPPER_BLOCK = :content_tag_wrapper

    def initialize(*)
      super

      # DEPRECATED
      define CONTENT_TAG_WRAPPER_BLOCK, defaults: { wrapper_tag: :div } do |content_block, *args|
        options = args.extract_options!
        wrapper_options = if options[:wrapper_html_option]
          if options[:wrapper_html_option].is_a?(Array)
            wrapper_attribute = nil
            options[:wrapper_html_option].each do |attribute|
              if options[attribute].present?
                wrapper_attribute = attribute
                break
              end
            end
            options[wrapper_attribute]
          else
            options[options[:wrapper_html_option]]
          end
        end
        view.content_tag options[:wrapper_tag],
          concatenating_merge(options[:wrapper_html], wrapper_options, *args, options),
          &content_block
      end
    end
  end
end