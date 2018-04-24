require 'spec_helper'

feature "Rendering Strategies" do
  block_name = :my_block

  context "Rendering a Ruby Block" do
    my_block = Proc.new { "My Block" }
    before do
      builder.define(block_name, &my_block)
    end

    include_examples RENDERABLE, template: my_block, block_identifier: block_name
    include_examples CAN_BE_RENDERED_AS_AN_ADJACENT_BLOCK, template: my_block.call, block_identifier: block_name
  end

  context "Rendering a Ruby Block that 'yields' to another Ruby Block" do
    my_block = Proc.new {|content_block| "BEFORE #{content_block.call} AFTER" }
    runtime_block = Proc.new { "HELLO_WORLD" }
    template = Proc.new { my_block.call(runtime_block) }
    before do
      builder.define(block_name, &my_block)
    end

    include_examples RENDERABLE, template: template, block_identifier: block_name, runtime_block: runtime_block
    include_examples CAN_BE_RENDERED_AS_A_SURROUNDING_BLOCK, template: "BEFORE CONTENT AFTER", block_identifier: block_name
  end

  context "Rendering a Partial" do
    template = Proc.new { view.render(partial: 'my_partial') }
    before do
      builder.define block_name, partial: 'my_partial'
    end

    include_examples RENDERABLE, template: template, block_identifier: block_name
    include_examples CAN_BE_RENDERED_AS_AN_ADJACENT_BLOCK, template: template.call, block_identifier: block_name
    include_examples CAN_BE_RENDERED_AS_A_SURROUNDING_BLOCK, template: template.call, block_identifier: block_name
  end

  context "Rendering a Partial that 'yields' to another Ruby Block" do
    runtime_block = Proc.new { "TEST" }
    template = Proc.new { "HELLO TEST GOODBYE" }
    before do
      builder.define(block_name, partial: "yielding_partial", before_content: "HELLO", after_content: "GOODBYE")
    end

    include_examples RENDERABLE, template: template, block_identifier: block_name, runtime_block: runtime_block
    include_examples CAN_BE_RENDERED_AS_AN_ADJACENT_BLOCK, template: "HELLO CONTENT GOODBYE", block_identifier: block_name
    include_examples CAN_BE_RENDERED_AS_A_SURROUNDING_BLOCK, template: "HELLO CONTENT GOODBYE", block_identifier: block_name
  end

  context "Rendering a Proxy" do
    template = Proc.new { "Some other content" }
    before do
      builder.define(:some_other_block) do
        "Some other content"
      end
      builder.define(block_name, with: :some_other_block)
    end

    include_examples RENDERABLE, template: template, block_identifier: block_name
    include_examples CAN_BE_RENDERED_AS_AN_ADJACENT_BLOCK, template: template.call, block_identifier: block_name
  end

  context "Rendering a Proxy that 'yields' to another block" do
    my_block = Proc.new {|content_block| "BEFORE #{content_block.call} AFTER" }
    runtime_block = Proc.new { "HELLO_WORLD" }
    template = Proc.new { my_block.call(runtime_block) }
    before do
      builder.define(:some_other_block, &my_block)
      builder.define(block_name, with: :some_other_block)
    end

    include_examples RENDERABLE, template: template, block_identifier: block_name, runtime_block: runtime_block
    include_examples CAN_BE_RENDERED_AS_A_SURROUNDING_BLOCK, template: "BEFORE CONTENT AFTER", block_identifier: block_name
  end
end
