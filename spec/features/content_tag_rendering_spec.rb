require 'spec_helper'

feature "The :content_tag Block" do
  runtime_block =  Proc.new { "Hello World" }

  before do
    builder.define :some_block do
      "Some Block"
    end

    builder.define :some_item do |item|
      "My Item #{item}"
    end
  end

  context 'when called directly as a method' do
    it 'be callable with the tag, options, and block' do
      content = builder.content_tag :h1, class: "header" do
        "My Header"
      end
      expect(content).to eql '<h1 class="header">My Header</h1>'
    end

    it 'should not require a block to be specified' do
      content = builder.content_tag :h1, "My Header", class: "header"
      expect(content).to eql '<h1 class="header">My Header</h1>'
    end

    it 'should default the tag to div' do
      content = builder.content_tag class: "header" do
        "My Header"
      end
      expect(content).to eql '<div class="header">My Header</div>'
    end

    it 'should be able to specify the content tag as a hash option' do
      content = builder.content_tag tag: :h1, class: "header" do
        "My Header"
      end
      expect(content).to eql '<h1 class="header">My Header</h1>'
    end

    it 'should be able to specify the content as a hash option' do
      content = builder.content_tag tag: :h1, class: "header", content: "My Header"
      expect(content).to eql '<h1 class="header">My Header</h1>'
    end
  end

  it "should allow an array of html options to be specified for a wrapper and detect the first one set" do
    builder.define :some_block,
      wrap_each: :content_tag,
      wrap_each_tag: :li,
      wrap_each_html_option: [:item_html, :list_item_html, :li_html],
      list_item_html: { class: "header" },
      li_html: { class: "ignored" },
      wrap_all: :content_tag,
      wrap_all_tag: :ul,
      wrap_all_html_option: [:list_html, :ul_html],
      list_html: { id: "my-list" },
      ul_html: { class: "ignored" },
      wrapper: :content_tag,
      wrapper_tag: :a,
      wrapper_html_option: [:link_html, :a_html],
      wrapper_html: { href: "#", class: "my-link" }
    content = builder.render :some_block
    expect(content).to closely_resemble_html %%
      <ul id="my-list">
        <li class="header">
          <a href="#" class="my-link">Some Block</a>
        </li>
      </ul>
    %
  end

  it "should be able to fallback to the default html attribute when the specified attribute is not present" do
    builder.define :some_block,
      wrap_each: :content_tag,
      wrap_each_tag: :li,
      wrap_each_html_option: :item_html,
      wrap_each_html: { class: "header" },
      wrap_all: :content_tag,
      wrap_all_tag: :ul,
      wrap_all_html_option: [:list_html, :ul_html],
      wrap_all_html: { id: "my-list" },
      wrapper: :content_tag,
      wrapper_tag: :a,
      wrapper_html_option: :link_html,
      wrapper_html: { href: "#", class: "my-link" }
    content = builder.render :some_block
    expect(content).to closely_resemble_html %%
      <ul id="my-list">
        <li class="header">
          <a href="#" class="my-link">Some Block</a>
        </li>
      </ul>
    %
  end

  it "should be able to render each item in a collection with content tag hooks and wrappers" do
    builder.define :some_item,
      wrap_each: :content_tag,
      wrap_each_tag: :li,
      wrap_each_html: { class: "header" },
      wrap_all: :content_tag,
      wrap_all_tag: :ul,
      wrap_all_html: { id: "my-list" },
      wrapper: :content_tag,
      wrapper_tag: :a,
      wrapper_html: { href: "#", class: "my-link" }
    builder.around_all :some_item,
      with: :content_tag,
      tag: :div,
      html: { id: 'around-all-1' }
    builder.around_all :some_item,
      with: :content_tag,
      tag: :div,
      html: { id: 'around-all-2' }
    builder.around :some_item,
      with: :content_tag,
      tag: :div,
      html: { id: 'around-1' }
    builder.around :some_item,
      with: :content_tag,
      tag: :div,
      html: { id: 'around-2' }
    builder.surround :some_item,
      with: :content_tag,
      tag: :div,
      html: { id: 'surround-1' }
    builder.surround :some_item,
      with: :content_tag,
      tag: :div,
      html: { id: 'surround-2' }
    content = builder.render :some_item, collection: [1, 2, 3]
    expect(content).to closely_resemble_html %%
      <div id="around-all-2">
        <div id="around-all-1">
          <ul id="my-list">
            <li class="header">
              <div id="around-2">
                <div id="around-1">
                  <a href="#" class="my-link">
                    <div id="surround-2">
                      <div id="surround-1">My Item 1</div>
                    </div>
                  </a>
                </div>
              </div>
            </li>
            <li class="header">
              <div id="around-2">
                <div id="around-1">
                  <a href="#" class="my-link">
                    <div id="surround-2">
                      <div id="surround-1">My Item 2</div>
                    </div>
                  </a>
                </div>
              </div>
            </li>
            <li class="header">
              <div id="around-2">
                <div id="around-1">
                  <a href="#" class="my-link">
                    <div id="surround-2">
                      <div id="surround-1">My Item 3</div>
                    </div>
                  </a>
                </div>
              </div>
            </li>
          </ul>
        </div>
      </div>
    %
  end

  include_examples CAN_BE_RENDERED_AS_A_HOOK_OR_WRAPPER,
    template: %%
      <div HTML_OPTIONS>
        CONTENT
      </div>
    %,
    block_identifier: :content_tag

  include_examples RENDERABLE,
    template: Proc.new {|options={}|
      %%
        <div id="my-block#{options[:object]}">
          #{runtime_block.call}
        </div>
      %
    },
    block_identifier: :content_tag,
    options: { html: { id: Proc.new {|options| "my-block#{options[:object]}" }} },
    runtime_block: runtime_block

  context 'when provided a different html tag' do
    options = { tag: :span }

    include_examples RENDERABLE,
      template: Proc.new {|options={}|
        %%
          <span id="my-block#{options[:object]}">
            #{runtime_block.call}
          </span>
        %
      },
      block_identifier: :content_tag,
      options: options.merge(html: { id: Proc.new {|options| "my-block#{options[:object]}" }}),
      runtime_block: runtime_block

    include_examples CAN_BE_RENDERED_AS_A_HOOK_OR_WRAPPER,
      template:  %%
        <span HTML_OPTIONS>
          CONTENT
        </span>
      %,
      options: options,
      block_identifier: :content_tag
  end
end