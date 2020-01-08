RENDERABLE = 'renderable'

module RenderingSupport
  extend RSpec::SharedContext

  let(:builder) { TestBuilder.new(view) }
end

def sanitize_html(content)
    # trim_html(content)
  # # content = content.split("\n").map do |line|
  #   fields = content.split(/\s*(\w+)\s*=\s*['"]([\w\-#]+)['"]/).reject(&:blank?)
  #   content = ""
  #   fields.each do |field|
  #     value
  #   end
    # if fields.length == 1
      # fields
    # else
      # fields[0] + fields[1..-2].in_groups_of(2).sort {|a, b| a[0] < b[0] }.map do |field, value|
        # "#{field}=\'#{value}\'"
      # end.join(" ") + fields[-1]
    # end
  # end.join("")
  content.gsub(/\s\s+/, "").gsub("\n", "")
end

shared_examples RENDERABLE do |template: nil, block_identifier: nil, options: {}, runtime_block: nil|
  # context "with #{block_identifier} as the block name" do
  #   it "will render" do
  #     content = sanitize_html(builder.render(block_identifier, options, &runtime_block))
  #     expect(content).to eql sanitize_html(template.call(options))
  #   end

  #   it "will render multiple times for a collection" do
  #     collection = ["a", :b, 3]
  #     content = sanitize_html(builder.render(block_identifier, options.merge(collection: collection), &runtime_block))
  #     expected_content = collection.map {|item| template.call(object: item)}.join
  #     expect(content).to eql sanitize_html(expected_content)
  #   end

  #   it "will render with hooks and wrappers that were applied to #{block_identifier}" do
  #     results = builder.apply_hooks_and_wrappers_to_block_and_render(
  #       block_identifier,
  #       content: template.call,
  #       options: options,
  #       &runtime_block
  #     )

  #     expect(results[:actual]).to eql results[:expected]
  #   end

  #   it "can be overridden with a proxy block" do
  #     builder.define :proxy do
  #       "Replacement"
  #     end
  #     content = sanitize_html(builder.render(block_identifier, with: :proxy, &runtime_block))
  #     expect(content).to eql "Replacement"
  #   end

  #   it "can be overridden with a partial" do
  #     content = sanitize_html(builder.render(block_identifier, partial: "my_partial", &runtime_block))
  #     expect(content).to eql view.render(partial: "my_partial")
  #   end

  #   if TestBuilder.respond_to?(block_identifier)
  #     it "can be overridden by defining a block with the same name" do
  #       builder.define block_identifier do
  #         "Replacement"
  #       end
  #       expect(content).to eql "Replacement"
  #     end
  #   end
  # end

  context "with #{block_identifier} as a proxy" do
    let(:content) { sanitize_html(builder.render(options.merge(with: block_identifier), &runtime_block)) }
    it "will render" do
      expect(content).to eql sanitize_html(template.call)
    end

    it "will render multiple times for a collection" do
      collection = ["a", :b, 3]
      content = sanitize_html(builder.render(options.merge(collection: collection, with: block_identifier), &runtime_block))
      expected_content = collection.map {|item| template.call(object: item)}.join
      expect(content).to eql sanitize_html(expected_content)
    end

    it "will render with an alias" do
      content = sanitize_html(builder.render(:some_block, options.merge(with: block_identifier), &runtime_block))
      expect(content).to eql sanitize_html(template.call)
    end

    # TODO: should hooks also be applied when no block name is provided? I'm thinking so.
    xit "will fallback to wrappers applied to #{block_identifier} when not defined for the alias" do
      builder.apply_hooks_to_block(block_identifier) # these won't get rendered
      results = builder.apply_hooks_and_wrappers_to_block_and_render(
        block_identifier,
        block_to_render: :my_alias,
        adjacent_hooks: false,
        around_hooks: false,
        content: template.call,
        options: options.merge(with: block_identifier),
        &runtime_block
      )

      expect(results[:actual]).to eql results[:expected]
    end
  end

  context "with #{block_identifier} as the proxy for another block being rendered" do
    before do
      builder.define(:test_block, with: block_identifier)
    end

    it "will render" do
      content = sanitize_html(builder.render(:test_block, options, &runtime_block))
      expect(content).to eql sanitize_html(template.call)
    end

    it "will render multiple times for a collection" do
      collection = ["a", :b, 3]
      content = sanitize_html(builder.render(:test_block, options.merge(collection: collection), &runtime_block))
      expected_content = collection.map {|item| template.call(object: item)}.join
      expect(content).to eql sanitize_html(expected_content)
    end

    xit "will render multiple times for a collection with hooks and wrappers applied to the block being rendered" do
      collection = ["a", :b, 3]
      builder.apply_hooks_to_block(block_identifier) # these won't get rendered
      builder.apply_wrappers_to_block(block_identifier) # these won't get rendered

      results = builder.apply_hooks_and_wrappers_to_block_and_render(
        :test_block,
        content: template,
        options: options.merge(collection: collection),
        &runtime_block
      )

      expect(results[:actual]).to eql results[:expected]
    end

    xit "will render with hooks and wrappers applied to the block being rendered" do
      builder.apply_hooks_to_block(block_identifier) # these won't get rendered
      builder.apply_wrappers_to_block(block_identifier) # these won't get rendered

      results = builder.apply_hooks_and_wrappers_to_block_and_render(
        :test_block,
        content: template.call,
        options: options,
        &runtime_block
      )

      expect(results[:actual]).to eql results[:expected]
    end

    xit "will fallback to wrappers applied to #{block_identifier} if not present on the block being rendered" do
      builder.apply_hooks_to_block(block_identifier) # these won't get rendered

      results = builder.apply_hooks_and_wrappers_to_block_and_render(
        block_identifier,
        block_to_render: :test_block,
        adjacent_hooks: false,
        around_hooks: false,
        content: template.call,
        options: options,
        &runtime_block
      )

      expect(results[:actual]).to eql results[:expected]
    end
  end
end