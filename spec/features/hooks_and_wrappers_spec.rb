require 'spec_helper'

describe "Hooks and Wrappers feature" do
  def with_default_options(hooks: true, wrappers: true, collection: nil,
                           block_or_partial: :block,
                           render_with_different_block: false)
    {
      hooks: hooks,
      wrappers: wrappers,
      collection: collection,
      block_or_partial: block_or_partial,
      render_with_different_block: render_with_different_block
    }
  end

  context 'for the hooks and wrappers feature' do
    [[1, 2], nil].each do |collection|
      collection_message = collection.present? ? "a collection of blocks" : "a single block"
      context "when rendering #{collection_message}" do
        truth_variations = [true, false].repeated_permutation(2)

        truth_variations.each do |hooks, wrappers|
          message_variant = { true => "using", false => "not using" }
          context "when #{message_variant[hooks]} hooks and #{message_variant[wrappers]} wrappers" do
            it "should render properly" do
              html = render_template_and_compare_to_fixture(
                :block_rendering,
                collection: collection,
                wrappers: wrappers,
                hooks: hooks
              )
              expect(html).to include "Actual block"
            end

            it "should still render properly even if the block being rendered is not defined" do
              html = render_template_and_compare_to_fixture(
                :block_rendering,
                collection: collection,
                wrappers: wrappers,
                hooks: hooks,
                block_or_partial: nil
              )
              expect(html).not_to include "Actual block"
            end

            it "should still render properly even if the block being rendered is to be rendered with a partial" do
              html = render_template_and_compare_to_fixture(
                :block_rendering,
                collection: collection,
                wrappers: wrappers,
                hooks: hooks,
                block_or_partial: "/content.html"
              )
              expect(html).to include "Content in partial"
            end

            it "should still render properly even if the block being rendered is to be rendered with a different block" do
              html = render_template_and_compare_to_fixture(
                :block_rendering,
                collection: collection,
                wrappers: wrappers,
                hooks: hooks,
                render_with_different_block: true
              )
              expect(html).to include "Some other block"
            end
          end
        end
      end
    end
  end
end
