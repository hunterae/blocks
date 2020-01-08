BEFORE_HOOKS, AFTER_HOOKS =
  Blocks::HookDefinition::HOOKS.reject {|hook| hook.to_s.include?("around") || hook.to_s.include?("surround") }.
  partition {|hook| hook.to_s.index("before") == 0 || hook.to_s.index("prepend") == 0 }

AROUND_HOOKS = Blocks::HookDefinition::HOOKS - BEFORE_HOOKS - AFTER_HOOKS

WRAPPERS = [:wrap_all, :wrap_each, :wrapper]

# Renderable as a surrounding or wrapper block
CAN_BE_RENDERED_AS_A_SURROUNDING_BLOCK = 'a block renderable around around another block'

# Renderable as an adjacent block
CAN_BE_RENDERED_AS_AN_ADJACENT_BLOCK = 'a block renderable adjacent to another block'

CAN_BE_RENDERED_AS_A_HOOK_OR_WRAPPER = 'a block renderable as a hook or wrapper'
CAN_BE_RENDERED_AS_A_SPECIFIC_HOOK = 'a block renderable as a specific hook'

# shared_examples CAN_BE_RENDERED_AS_A_WRAPPER do

shared_examples CAN_BE_RENDERED_AS_A_SPECIFIC_HOOK do |hook_type: nil, template: nil, block_identifier: nil, html_option: :html, options: {}|
  context "when used as a #{hook_type} hook" do
    let(:block_name) { TestBuilder::SOME_BLOCK }
    let(:is_before_hook?) { BEFORE_HOOKS.include?(hook_type) }
    let(:is_around_hook?) { AROUND_HOOKS.include?(hook_type) }
    let(:is_after_hook?) { AFTER_HOOKS.include?(hook_type) }

    it "can be registered multiple times and renders in the appropriate place and order" do
      if is_around_hook?
        expected_content = template.gsub("CONTENT", block_name)
      else
        expected_content = block_name
      end

      # Register 3 hooks of type specified by hook_type to render in relation to the block
      3.times do |i|
        html = { id: "#{hook_type}-#{i+1}" }
        html_option_fields = html.map do |key, value|
          "#{key}=\"#{value}\""
        end.join(" ")

        hook_inner_content = "#{hook_type} #{i + 1}"

        builder.send hook_type,
          block_name,
          options.deep_merge(html_option => html, with: block_identifier) do
          hook_inner_content
        end

        if is_around_hook?
          expected_content = expected_content.gsub("HTML_OPTIONS", html_option_fields)
          expected_content = template.gsub("CONTENT", expected_content) if i < 2
        elsif is_before_hook?
          expected_content = template.gsub("HTML_OPTIONS", html_option_fields).gsub("CONTENT", hook_inner_content) + expected_content
        else
          expected_content = expected_content + template.gsub("HTML_OPTIONS", html_option_fields).gsub("CONTENT", hook_inner_content)
        end
      end

      content = sanitize_html(builder.render block_name)
      expect(content).to eql sanitize_html(expected_content)
    end

    it "can itself have a complete set of hooks and wrappers" do
      html = { id: "block-#{hook_type}" }
      html_option_fields = html.map do |key, value|
        "#{key}=\"#{value}\""
      end.join(" ")

      if is_around_hook?
        builder.send hook_type,
          block_name,
          options.deep_merge(html_option => html, with: block_identifier)
      else
        builder.send hook_type,
          block_name,
          options.deep_merge(html_option => html, with: block_identifier) do
          "block-#{hook_type}"
        end
      end

      if is_around_hook?
        expected_block_content = template.gsub("HTML_OPTIONS", html_option_fields).gsub("CONTENT", "Some Block Name")
      else
        expected_block_content = template.gsub("HTML_OPTIONS", html_option_fields).gsub("CONTENT", "block-#{hook_type}")
      end
      results = builder.apply_hooks_and_wrappers_to_block_and_render(block_identifier, block_to_render: block_name, content: expected_block_content)

      if is_around_hook?
        expect(results[:actual]).to eql results[:expected]
      elsif is_before_hook?
        expect(results[:actual]).to eql "#{results[:expected]}Some Block Name"
      else
        expect(results[:actual]).to eql "Some Block Name#{results[:expected]}"
      end
    end

    context "when provided a rendering alias" do
      xit "will render a different hooks and wrappers using the alias as its name" do
        options = options.merge(render: :hello_world)

        html = { id: "block-#{hook_type}" }
        html_option_fields = html.map do |key, value|
          "#{key}=\"#{value}\""
        end.join(" ")
        if is_around_hook?
          builder.send hook_type,
            block_name,
            options.deep_merge(html_option => html, with: block_identifier)
        else
          builder.send hook_type,
            block_name,
            options.deep_merge(html_option => html, with: block_identifier) do
            "block-#{hook_type}"
          end
        end

        if is_around_hook?
          expected_block_content = template.gsub("HTML_OPTIONS", html_option_fields).gsub("CONTENT", "Some Block Name")
        else
          expected_block_content = template.gsub("HTML_OPTIONS", html_option_fields).gsub("CONTENT", "block-#{hook_type}")
        end
        results = builder.apply_hooks_and_wrappers_to_block_and_render(:hello_world, block_to_render: block_name, content: expected_block_content)

        if is_around_hook?
          expect(results[:actual]).to eql results[:expected]
        elsif is_before_hook?
          expect(results[:actual]).to eql "#{results[:expected]}Some Block Name"
        else
          expect(results[:actual]).to eql "Some Block Name#{results[:expected]}"
        end
      end

      xit "ignores any hooks applied to #{block_identifier}" do
        builder.apply_hooks_to_block(block_identifier)
        options = options.merge(render: :hello_world)

        html = { id: "block-#{hook_type}" }
        html_option_fields = html.map do |key, value|
          "#{key}=\"#{value}\""
        end.join(" ")
        if is_around_hook?
          builder.send hook_type,
            block_name,
            options.deep_merge(html_option => html, with: block_identifier)
        else
          builder.send hook_type,
            block_name,
            options.deep_merge(html_option => html, with: block_identifier) do
            "block-#{hook_type}"
          end
        end

        if is_around_hook?
          expected_block_content = template.gsub("HTML_OPTIONS", html_option_fields).gsub("CONTENT", "Some Block Name")
        elsif is_before_hook?
          expected_block_content = template.gsub("HTML_OPTIONS", html_option_fields).gsub("CONTENT", "block-#{hook_type}") + "Some Block Name"
        else
          expected_block_content = "Some Block Name" + template.gsub("HTML_OPTIONS", html_option_fields).gsub("CONTENT", "block-#{hook_type}")
        end

        content = sanitize_html builder.render(block_name)

        expect(content).to eql sanitize_html(expected_block_content)
      end

      xit "should fallback to wrappers specified for #{block_identifier} if unspecified for the alias block" do
        options = options.merge(render: :hello_world)

        html = { id: "block-#{hook_type}" }
        html_option_fields = html.map do |key, value|
          "#{key}=\"#{value}\""
        end.join(" ")
        if is_around_hook?
          builder.send hook_type,
            block_name,
            options.deep_merge(html_option => html, with: block_identifier)
        else
          builder.send hook_type,
            block_name,
            options.deep_merge(html_option => html, with: block_identifier) do
            "block-#{hook_type}"
          end
        end

        if is_around_hook?
          expected_block_content = template.gsub("HTML_OPTIONS", html_option_fields).gsub("CONTENT", "Some Block Name")
        else
          expected_block_content = template.gsub("HTML_OPTIONS", html_option_fields).gsub("CONTENT", "block-#{hook_type}")
        end
        builder.apply_hooks_to_block(block_identifier)
        results = builder.apply_hooks_and_wrappers_to_block_and_render(block_identifier, adjacent_hooks: false, around_hooks: false, block_to_render: block_name, content: expected_block_content)

        if is_around_hook?
          expect(results[:actual]).to eql results[:expected]
        elsif is_before_hook?
          expect(results[:actual]).to eql "#{results[:expected]}Some Block Name"
        else
          expect(results[:actual]).to eql "Some Block Name#{results[:expected]}"
        end
      end
    end
  end
end

shared_examples CAN_BE_RENDERED_AS_A_HOOK_OR_WRAPPER do |options|
  include_examples CAN_BE_RENDERED_AS_A_SURROUNDING_BLOCK, options
  include_examples CAN_BE_RENDERED_AS_AN_ADJACENT_BLOCK, options
end

shared_examples CAN_BE_RENDERED_AS_AN_ADJACENT_BLOCK do |options|
  (BEFORE_HOOKS + AFTER_HOOKS).each do |hook_type|
    include_examples CAN_BE_RENDERED_AS_A_SPECIFIC_HOOK, options.merge(hook_type: hook_type)
  end
end

shared_examples CAN_BE_RENDERED_AS_A_SURROUNDING_BLOCK do |template: nil, block_identifier: nil, html_option: :html, options: {}|
  let(:block_name) { TestBuilder::SOME_BLOCK }

  it "should be able to change the html_option for wrappers for a block" do
    expected_content = template.gsub("CONTENT", block_name)
    wrapper_options = {
      wrap_all: block_identifier,
      wrap_each: block_identifier,
      wrapper: block_identifier,
      wrap_all_html_option: :outer_html,
      wrap_each_html_option: :middle_html,
      wrapper_html_option: :inner_html,
      outer_html: { id: "wrap-all" },
      middle_html: { id: "wrap-each" },
      inner_html: { id: "wrapper" }
    }
    options.each do |key, value|
      wrapper_options["wrap_all_#{key}".to_sym] = value
      wrapper_options["wrap_each_#{key}".to_sym] = value
      wrapper_options["wrapper_#{key}".to_sym] = value
    end
    expected_content = expected_content.gsub("HTML_OPTIONS", "id=\"wrapper\"")
    expected_content = template.gsub("CONTENT", expected_content)
    expected_content = expected_content.gsub("HTML_OPTIONS", "id=\"wrap-each\"")
    expected_content = template.gsub("CONTENT", expected_content)
    expected_content = expected_content.gsub("HTML_OPTIONS", "id=\"wrap-all\"")

    builder.define block_name, wrapper_options
    content = sanitize_html(builder.render block_name)
    expect(content).to eql sanitize_html(expected_content)
  end

  it "should be able to use wrappers for a block" do
    expected_content = template.gsub("CONTENT", block_name)
    wrapper_options = {
      wrap_all: block_identifier,
      wrap_each: block_identifier,
      wrapper: block_identifier,
      "wrap_all_#{html_option}".to_sym => { id: "wrap-all" },
      "wrap_each_#{html_option}".to_sym => { id: "wrap-each" },
      "wrapper_#{html_option}".to_sym => { id: "wrapper" }
    }
    options.each do |key, value|
      wrapper_options["wrap_all_#{key}".to_sym] = value
      wrapper_options["wrap_each_#{key}".to_sym] = value
      wrapper_options["wrapper_#{key}".to_sym] = value
    end
    expected_content = expected_content.gsub("HTML_OPTIONS", "id=\"wrapper\"")
    expected_content = template.gsub("CONTENT", expected_content)
    expected_content = expected_content.gsub("HTML_OPTIONS", "id=\"wrap-each\"")
    expected_content = template.gsub("CONTENT", expected_content)
    expected_content = expected_content.gsub("HTML_OPTIONS", "id=\"wrap-all\"")

    builder.define block_name, wrapper_options
    content = sanitize_html(builder.render block_name)
    expect(content).to eql sanitize_html(expected_content)
  end
  AROUND_HOOKS.each do |hook_type|
    include_examples CAN_BE_RENDERED_AS_A_SPECIFIC_HOOK, hook_type: hook_type, template: template, block_identifier: block_identifier, html_option: html_option, options: options
  end
end