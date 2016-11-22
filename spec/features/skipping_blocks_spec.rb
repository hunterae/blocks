require 'spec_helper'

feature "Skipping blocks" do
  def with_default_options(hooks: true, wrappers: true, collection: nil,
                           block_or_partial: :block,
                           render_with_different_block: false,
                           block_skipped: false)
    {
      hooks: hooks,
      wrappers: wrappers,
      collection: collection,
      block_or_partial: block_or_partial,
      render_with_different_block: render_with_different_block
    }
  end

  [[1, 2], nil].each do |collection|
    collection_message = collection.present? ? "a collection of blocks" : "a single block"
    context "when rendering #{collection_message}" do
      context 'when skipping the block' do
        before do
          view.blocks.skip :test_block
        end

        it 'should render everything except for the item wrapper, surrounding, prepended, and appended content' do
          html = render_template_and_compare_to_fixture(
            :block_rendering,
            with_default_options(
              collection: collection,
              wrappers: true,
              hooks: true,
              block_skipped: true
            )
          )
          expect(html).not_to include "Actual block"
        end
      end
    end
  end
end
