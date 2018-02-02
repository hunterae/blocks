require 'spec_helper'

feature "Content Tag Rendering" do
  let(:view) { ActionView::Base.new }
  let(:builder) { Blocks::Builder.new(view) }

  before do
    builder.define :some_block do
      "My Block"
    end

    builder.define :some_item do |item|
      "My Item #{item}"
    end
  end

  context 'when calling #content_tag directly' do
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
  end

  it "should be able to specify a different html attribute name for each wrapper" do
    builder.define :some_block,
      wrap_each: :content_tag,
      wrap_each_tag: :li,
      wrap_each_html_option: :item_html,
      item_html: { class: "header" },
      wrap_all: :content_tag,
      wrap_all_tag: :ul,
      wrap_all_html_option: :list_html,
      list_html: { id: "my-list" },
      wrapper: :content_tag,
      wrapper_tag: :a,
      wrapper_html_option: :link_html,
      link_html: { href: "#", class: "my-link" }
    content = builder.render :some_block
    expect(content).to eql %%
      <ul id="my-list">
        <li class="header">
          <a href="#" class="my-link">
            My Block
          </a>
        </li>
      </ul>
    %.gsub(/\s\s+/, "")
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
    expect(content).to eql %%
      <ul id="my-list">
        <li class="header">
          <a href="#" class="my-link">
            My Block
          </a>
        </li>
      </ul>
    %.gsub(/\s\s+/, "")
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
    expect(content).to eql %%
      <ul id="my-list">
        <li class="header">
          <a href="#" class="my-link">
                My Block
          </a>
        </li>
      </ul>
    %.gsub(/\s\s+/, "")
  end

  it "should be able to render a block with content tag hooks and wrappers" do
    builder.define :some_block,
      wrap_each: :content_tag,
      wrap_each_tag: :li,
      wrap_each_html: { class: "header" },
      wrap_all: :content_tag,
      wrap_all_tag: :ul,
      wrap_all_html: { id: "my-list" },
      wrapper: :content_tag,
      wrapper_tag: :a,
      wrapper_html: { href: "#", class: "my-link" }
    builder.around_all :some_block,
      with: :content_tag,
      tag: :div,
      html: { id: 'around-all-1' }
    builder.around_all :some_block,
      with: :content_tag,
      tag: :div,
      html: { id: 'around-all-2' }
    builder.around :some_block,
      with: :content_tag,
      tag: :div,
      html: { id: 'around-1' }
    builder.around :some_block,
      with: :content_tag,
      tag: :div,
      html: { id: 'around-2' }
    builder.surround :some_block,
      with: :content_tag,
      tag: :div,
      html: { id: 'surround-1' }
    builder.surround :some_block,
      with: :content_tag,
      tag: :div,
      html: { id: 'surround-2' }
    content = builder.render :some_block
    expect(content).to eql %%
      <div id="around-all-2">
        <div id="around-all-1">
          <ul id="my-list">
            <li class="header">
              <div id="around-2">
                <div id="around-1">
                  <a href="#" class="my-link">
                    <div id="surround-2">
                      <div id="surround-1">
                        My Block
                      </div>
                    </div>
                  </a>
                </div>
              </div>
            </li>
          </ul>
        </div>
      </div>
    %.gsub(/\s\s+/, "")
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
    expect(content).to eql %%
      <div id="around-all-2">
        <div id="around-all-1">
          <ul id="my-list">
            <li class="header">
              <div id="around-2">
                <div id="around-1">
                  <a href="#" class="my-link">
                    <div id="surround-2">
                      <div id="surround-1">
                        My Item 1
                      </div>
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
                      <div id="surround-1">
                        My Item 2
                      </div>
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
                      <div id="surround-1">
                        My Item 3
                      </div>
                    </div>
                  </a>
                </div>
              </div>
            </li>
          </ul>
        </div>
      </div>
    %.gsub(/\s\s+/, "")
  end
end