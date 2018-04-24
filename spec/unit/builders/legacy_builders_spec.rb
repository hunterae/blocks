require 'spec_helper'

describe Blocks::LegacyBuilders do
  let(:view) { Blocks::Builder.new(instance_double("ActionView::Base")) }
  subject { Blocks::Builder.new(view) }

  context 'Blocks::LegacyBuilders::CONTENT_TAG_WRAPPER_BLOCK' do
    it 'should use #content_tag to build a div around another block' do
      content = Proc.new {}
      expect(view).to receive(:content_tag).with(:div, {}, &content)
      wrapper = subject.block_definitions[Blocks::Builder::CONTENT_TAG_WRAPPER_BLOCK]
      wrapper_block = wrapper.standard_options[:block]
      wrapper_block.call(content, wrapper.default_options)
    end

    it 'should allow the override of the tag and options' do
      content = Proc.new {}
      expect(view).to receive(:content_tag).with(:span, class: "my-class", &content)
      wrapper = subject.block_definitions[Blocks::Builder::CONTENT_TAG_WRAPPER_BLOCK]
      wrapper_block = wrapper.standard_options[:block]
      wrapper_block.call(content, wrapper.default_options.merge(wrapper_tag: :span, wrapper_html: { class: "my-class" }))
    end

    it 'should check the wrapper_html_option to check for an additional option that may set the content tag options' do
      content = Proc.new {}
      expect(view).to receive(:content_tag).with(:div, style: "background-color: orange", class: "my-class", &content)
      wrapper = subject.block_definitions[Blocks::Builder::CONTENT_TAG_WRAPPER_BLOCK]
      wrapper_block = wrapper.standard_options[:block]
      wrapper_block.call(content, wrapper.default_options.merge(wrapper_html: { class: "my-class" }, wrapper_html_option: :other_options, other_options: { style: "background-color: orange"}))
    end

    it 'should allow an array of wrapper_html_option settings and use the first one that is set' do
      content = Proc.new {}
      expect(view).to receive(:content_tag).with(:div, style: "background-color: orange", &content)
      wrapper = subject.block_definitions[Blocks::Builder::CONTENT_TAG_WRAPPER_BLOCK]
      wrapper_block = wrapper.standard_options[:block]
      wrapper_block.call(content,
        wrapper.default_options.merge(
          wrapper_html_option: [:other_options_missing, :other_options_first, :other_options_last],
          other_options_first: { style: "background-color: orange"},
          other_options_last: { style: "background-color: green"},
        )
      )
    end

    it 'should allow the wrapper_html_option to specify a hash that has Procs as its values' do
      content = Proc.new {}
      expect(view).to receive(:content_tag).with(:div, id: "arg1", class: "arg2", &content)
      wrapper = subject.block_definitions[Blocks::Builder::CONTENT_TAG_WRAPPER_BLOCK]
      wrapper_block = wrapper.standard_options[:block]
      wrapper_block.call(content,
        "arg1",
        "arg2",
        wrapper.default_options.merge(
          wrapper_html_option: :other_options,
          other_options: {
            id: Proc.new {|arg1| arg1 },
            class: Proc.new {|arg1, arg2| arg2 }
          }
        )
      )
    end
  end
end