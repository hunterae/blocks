require 'spec_helper'

feature "Rendering with Hooks and Wrappers" do
  def with_default_options(options={})
    options[:hooks] ||= true
    options[:wrappers] ||= true
    options[:collection] ||= nil
    options[:block_or_partial] = :block if !options.key?(:block_or_partial)
    options[:render_with_different_block] ||= false
    options[:block_skipped] = false
    options
  end

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
              with_default_options(
                collection: collection,
                wrappers: wrappers,
                hooks: hooks
              )
            )
            expect(html).to include "Actual block"
          end

          it "should still render properly even if the block being rendered is not defined" do
            html = render_template_and_compare_to_fixture(
              :block_rendering,
              with_default_options(
                collection: collection,
                wrappers: wrappers,
                hooks: hooks,
                block_or_partial: nil
              )
            )
            expect(html).not_to include "Actual block"
          end

          it "should still render properly even if the block being rendered is to be rendered with a partial" do
            html = render_template_and_compare_to_fixture(
              :block_rendering,
              with_default_options(
                collection: collection,
                wrappers: wrappers,
                hooks: hooks,
                block_or_partial: "/content.html"
              )
            )
            expect(html).to include "Content in partial"
            expect(html).not_to include "Actual block"
          end

          it "should still render properly even if the block being rendered is to be rendered with a different block" do
            html = render_template_and_compare_to_fixture(
              :block_rendering,
              with_default_options(
                collection: collection,
                wrappers: wrappers,
                hooks: hooks,
                render_with_different_block: true
              )
            )
            expect(html).to include "Some other block"
            expect(html).not_to include "Actual block"
          end
        end
      end
    end
  end
end
