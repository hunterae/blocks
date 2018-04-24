require 'spec_helper'

feature "Rendering Haml" do
  haml_partial = "haml_partial"
  erb_partial = "erb_partial"
  haml_layout = "haml_layout"
  erb_layout = "erb_layout"
  block_name = :test_block

  layout_template = Proc.new do |content, partial_block_content=nil|
    %%
      BEFORE_LAYOUT
      #{content}
      #{partial_block_content}
      AFTER_LAYOUT
    %
  end
  partial_template = %%
    BEFORE_PARTIAL
    PARTIAL
    AFTER_PARTIAL
  %

  before do
    options = {
      before_layout_content: "BEFORE_LAYOUT",
      after_layout_content: "AFTER_LAYOUT",
      before_partial_content: "BEFORE_PARTIAL",
      after_partial_content: "AFTER_PARTIAL",
      partial_block_content: "PARTIAL_BLOCK",
      partial_content: "PARTIAL"
    }
    layout_options = {}
    builder.define haml_partial, options.merge(partial: haml_partial)
    builder.define erb_partial, options.merge(partial: erb_partial)
    builder.define haml_layout, options.merge(partial: haml_layout)
    builder.define erb_layout, options.merge(partial: erb_layout)
  end

  HAML_VARIATIONS = 'haml variations'
  [
    { layout: 'Haml', template: 'Haml' },
    { layout: 'ERB', template: 'Haml' },
    { layout: 'Haml', template: 'ERB' }
  ].each do |layout: nil, template: nil|
    it "be able to render a #{layout} layout with a #{template} template" do
      content = sanitize_html(
        builder.render(
          partial: "#{layout.downcase}_layout",
          before_layout_content: "BEFORE_LAYOUT",
          after_layout_content: "AFTER_LAYOUT",
          before_partial_content: "BEFORE_PARTIAL",
          after_partial_content: "AFTER_PARTIAL",
          partial_block_content: "PARTIAL_BLOCK_CONTENT",
          partial_content: "PARTIAL_CONTENT"
        ) do |builder, options|
          builder.render options.merge(partial: "#{template.downcase}_partial")
        end
      )
      expected_content = sanitize_html(%%
        BEFORE_LAYOUT
        BEFORE_PARTIAL
        PARTIAL_CONTENT
        AFTER_PARTIAL
        PARTIAL_BLOCK_CONTENT
        AFTER_LAYOUT
      %)
      expect(content).to eql expected_content
    end
  end

  it 'should be able to nest ERB and Haml hooks and wrappers' do
    builder.around_all block_name, with: haml_layout
    builder.around_all block_name, with: erb_layout
    builder.around block_name, with: erb_layout
    builder.around block_name, with: haml_layout
    builder.surround block_name, with: haml_layout
    builder.surround block_name, with: erb_layout
    builder.define block_name,
      wrap_all: haml_layout,
      wrap_each: erb_layout,
      wrapper: haml_layout

    expected_content = partial_template

    9.times do
      expected_content = layout_template.call(expected_content, "PARTIAL_BLOCK")
    end
    expected_content = sanitize_html(expected_content)

    content = sanitize_html(builder.render block_name, with: erb_partial)
    content2 = sanitize_html(builder.render block_name, with: haml_partial)
    expect(content).to eql content2
    expect(content).to eql expected_content
  end

  context "with a HAML partial" do
    include_examples RENDERABLE, template: Proc.new { partial_template }, block_identifier: haml_partial
    include_examples CAN_BE_RENDERED_AS_AN_ADJACENT_BLOCK, template: partial_template, block_identifier: haml_partial
  end

  context "with a HAML layout" do
    runtime_block = Proc.new { "HELLO_WORLD" }
    template = Proc.new { layout_template.call(runtime_block.call) }

    include_examples RENDERABLE, template: template, block_identifier: haml_layout, runtime_block: runtime_block
    include_examples CAN_BE_RENDERED_AS_A_SURROUNDING_BLOCK, template: layout_template.call("CONTENT"), block_identifier: haml_layout
  end
end
