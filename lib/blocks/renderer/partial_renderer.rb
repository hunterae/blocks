module Blocks
  class PartialRenderer < AbstractRenderer
    include HamlHelpers

    attr_accessor :builder

    delegate :view,
             :block_containers,
             :init_options,
             :definition_mode=,
              to: :builder

    def initialize(builder)
      self.builder = builder
    end

    def render(partial, options={}, &block)
      if block_given?
        self.definition_mode = Blocks::Builder::DEFINITION_MODE_TEMPLATE_OVERRIDES
        overrides_and_provided_content = without_haml_interference { view.capture(builder, &block) }
      end

      locals = Blocks.global_options.merge(init_options).merge(options).tap do |options|
        variable = options.delete(:builder_variable) || :builder
        options[variable] = builder
      end

      self.definition_mode = Blocks::Builder::DEFINITION_MODE_TEMPLATE_DEFAULTS
      without_haml_interference do
        view.render(layout: partial, locals: locals) do |*args|
          overrides_and_provided_content.to_str.gsub(/PLACEHOLDER_FOR_([\w]+)/) do |s|
            block_container = block_containers["#{$1}"]
            builder.render block_container.name, block_container, block_container.runtime_options
          end.html_safe if overrides_and_provided_content
        end
      end
    end
  end
end