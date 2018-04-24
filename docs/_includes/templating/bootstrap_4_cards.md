## Building a Bootstrap 4 Card

> According to Bootstrap's documentation, a standard card has the following markup:

```html
<div class="card" style="width: 20rem;">
  <img class="card-img-top" src="..." alt="Card image cap">
  <div class="card-block">
    <h4 class="card-title">Card title</h4>
    <p class="card-text">
      Some quick example text
    </p>
    <a href="#" class="btn btn-primary">Go somewhere</a>
  </div>
</div>
```

Templating is best demonstrated through example. In the following set of iterative examples, a template for rendering a [Bootstrap 4 Card](https://v4-alpha.getbootstrap.com/components/card/) will be defined and expanded upon with Blocks functionality.

### Creating a Template

> The following code would be added to a new file located at /app/views/shared/\_card.html.erb:

{% highlight erb %}
<% builder.define :card do %>
  <div class="card" style="width: 20rem;">
    <img class="card-img-top" src="..." alt="Card image cap">
    <div class="card-block">
      <h4 class="card-title">Card title</h4>
      <p class="card-text">
        Some quick example text
      </p>
      <a href="#" class="btn btn-primary">Go somewhere</a>
    </div>
  </div>
<% end %>
<%= builder.render :card %>
{% endhighlight %}

> Now, when the template is rendered, it will match the markup above exactly.

```erb
<%= render_with_overrides partial: "shared/card" %>
<!-- Since no overrides block is provided, this
     call is synonymous with: -->
<%= Blocks::Builder.new(self).render(partial: "shared/card") %>
```

```haml
= render_with_overrides partial: "shared/card"
#- Since no overrides block is provided, this
#-  call is synonymous with:
= Blocks::Builder.new(self).render(partial: "shared/card")
```

```ruby
builder = Blocks::Builder.new(view_context)
builder.render partial: "shared/card"
# Since no overrides block is provided, this
#  call is synonymous with:
builder.render partial: "shared/card"
```

Setting up a Template is simple. Simply create a Rails partial. That's the bare minimum that needs to be done, although an empty partial won't do anything useful.

In this example, we define a block called :card and then render it using the "builder" variable that is automatically defined within the partial.

Our output will match the sample markup above but that is because we have hardcoded the markup within the :card block definition. We'll need to make the block definitions more dynamic but before we do that, we should extract out more block definitions.

### Extracting Out Block Definitions

> /app/views/shared/\_card.html.erb:

{% highlight erb %}
<% builder.define :card do %>
  <div class="card" style="width: 20rem;">
    <%= builder.render :card_image %>
    <%= builder.render :card_content %>
  </div>
<% end %>

<% builder.define :card_image do %>
  <img class="card-img-top" src="..." alt="Card image cap">
<% end %>

<% builder.define :card_block do %>
  <div class="card-block">
    <%= builder.render :card_title %>
    <%= builder.render :card_text %>
    <%= builder.render :card_action %>
  </div>
<% end %>

<% builder.define :card_title do %>
  <h4 class="card-title">Card title</h4>
<% end %>

<% builder.define :card_text do %>
  <p class="card-text">
    Some quick example text
  </p>
<% end %>

<% builder.define :card_action do %>
  <a href="#" class="btn btn-primary">Go somewhere</a>
<% end %>

<% builder.define :card_content,
  with: :card_block %>

<%= builder.render :card %>
{% endhighlight %}

> The output from rendering this template will be the same as before

If you look at the sample markup for a card, hopefully you notice a pattern. It's something like this:

* A Card is an element with an associated CSS class and is made up of a card image and card content
  * A Card image is an image tag with an associated CSS class and an image path
  * Card Content is an element with an associated CSS class and is made up of a card title, card text, and a card action
    * A Card title is a h4 tag with an associated CSS class and text for the title
    * Card text is a p tag with an associated CSS class and text
    * A Card Action is a link button with associated CSS classes, a label for the button, and a path for the action.

While not every Bootstrap 4 card will follow this exact pattern, it is a good starting point for beginning to break down a card into pieces.

The code to the right defines the card element and breaks the main :card block into its two components: :card_image and :card_content.

The :card_image block renders the hardcoded image tag and the :card_content block sets itself up to proxy to the :card_block block. This is done in anticipation (based on having read ahead in the Bootstrap 4 Card documentation) of using something other than a card-block for the content of the card (more on this shortly).

### Extracting out the Wrappers

> /app/views/shared/\_card.html.erb:

{% highlight erb %}
<% builder.define :block_wrapper,
  defaults: {
    wrapper_tag: :div,
    wrapper_html: {},
    wrapper_option: :wrapper_html
  } do |block, options| %>
  <%= content_tag options[:wrapper_tag],
    options[options[:wrapper_option]],
    &block %>
<% end %>

<% builder.define :card,
  wrapper: :block_wrapper,
  wrapper_option: :card_html,
  defaults: {
    card_html: { class: "card" },
  } do %>
  <%= builder.render :card_image %>
  <%= builder.render :card_content %>
<% end %>

<% builder.define :card_image do %>
  <img class="card-img-top" src="..." alt="Card image cap">
<% end %>

<% builder.define :card_block,
  wrapper: :block_wrapper,
  wrapper_option: :card_content_html,
  defaults: {
    card_content_html: {
      class: "card-block"
    }
  } do %>
  <%= builder.render :card_title %>
  <%= builder.render :card_text %>
  <%= builder.render :card_action %>
<% end %>

<% builder.define :card_title,
  wrapper: :block_wrapper,
  wrapper_option: :card_title_html,
  wrapper_tag: :h4,
  defaults: {
    card_title_html: {
      class: "card-title",
    }
  } do %>
  Card title
<% end %>

<% builder.define :card_text,
  wrapper: :block_wrapper,
  wrapper_option: :card_text_html,
  wrapper_tag: :p,
  defaults: {
    card_text_html: { class: "card-text" }
  } do %>
  Some quick example text
<% end %>

<% builder.define :card_action do %>
  <a href="#" class="btn btn-primary">Go somewhere</a>
<% end %>

<% builder.define :card_content,
  with: :card_block %>

<%= builder.render :card %>
{% endhighlight %}

> The output from rendering this template will be the same as before

Perhaps it will also be noticed that every block defined renders an HTML element with nested content. This code is ripe for extraction into a common wrapper block.

In the code to the right, this is exactly what is happening. A new block is defined called :block_wrapper. The :block_wrapper block is setup to take a content_block as its first argument, which will automatically be passed in when :block_wrapper is used as a wrapper for another block. :block_wrapper also defines a couple default options, such as :wrapper_tag being set to :div, :wrapper_html being set to an empty hash, and :wrapper_option being set to :wrapper_html. These options are all used within the :block_wrapper definition, where it builds an HTML element around the content_block. The element will be the :wrapper_tag option type and have attributes specified by the option specified by the :wrapper_option option, which will be :wrapper_html by default.

Because all of :block_wrapper's options are default options, they are easily overridden by the block being wrapper. For example, the :card block sets wrapper to :block_wrapper and its :wrapper_option to :card_html. Then it sets its default options for :card_html to { class: "card" }. By setting :card_html as a default option for :card, it can easily be overridden by the "render_with_overrides" call that will be demonstrated shortly.

<aside class="notice">Notice that :card did not need to declare it's :wrapper_tag as :div since it is already being defaulted to :div by :block_wrapper</aside>

:card_block, :card_title, and :card_text each follow the same paradigm. Notice that :card_text overrides the :wrapper_tag to :p and :card_title overrides it to :h4.

<aside class="notice">This paradigm of using a block wrapper that wraps a block within an HTML element is so common, that Blocks provides a similar block by default called :content_tag_wrapper (also accessible as the constant Blocks::Builder::CONTENT_TAG_WRAPPER_BLOCK). If this automatically defined block is used instead, the code to the right would only need to change by removing the :block_wrapper definition and changing all references to :block_wrapper to Blocks::Builder::CONTENT_TAG_WRAPPER_BLOCK.</aside>

<aside class="notice">The only two blocks that are not using the :block_wrapper are :card_image and :card_action. While both could utilize the :block_wrapper wrapper, it makes more sense not to do so. This will enable us to utilize Rails' link_to and image_tag helper methods instead, since links and images need a bit more fine-tuning than regular HTML elements.</aside>


### Making the Blocks more Dynamic

> /app/views/shared/\_card.html.erb:

{% highlight erb %}
<% builder.define :block_wrapper,
  defaults: {
    wrapper_tag: :div,
    wrapper_html: {},
    wrapper_option: :wrapper_html
  } do |block, options| %>
  <%= content_tag options[:wrapper_tag],
    options[options[:wrapper_option]],
    &block %>
<% end %>

<% builder.define :card,
  wrapper: :block_wrapper,
  wrapper_option: :card_html,
  defaults: {
    card_html: { class: "card" },
  } do %>
  <%= builder.render :card_image %>
  <%= builder.render :card_content %>
<% end %>

<% builder.define :card_image,
  defaults: {
    card_image: "placeholder.jpg",
    card_image_html: { class: "card-img-top" }
  } do |options| %>
  <%= image_tag options[:card_image],
    options[:card_image_html] %>
<% end %>

<% builder.define :card_block,
  wrapper: :block_wrapper,
  wrapper_option: :card_block_html,
  defaults: {
    card_block_html: {
      class: "card-block"
    }
  } do %>
  <%= builder.render :card_title %>
  <%= builder.render :card_text %>
  <%= builder.render :card_action %>
<% end %>

<% builder.define :card_title,
  wrapper: :block_wrapper,
  wrapper_option: :card_title_html,
  wrapper_tag: :h4,
  defaults: {
    card_title_html: {
      class: "card-title",
    },
    card_title: "Card title"
  } do |options| %>
  <%= options[:card_title] %>
<% end %>

<% builder.define :card_text,
  wrapper: :block_wrapper,
  wrapper_option: :card_text_html,
  wrapper_tag: :p,
  defaults: {
    card_text_html: { class: "card-text" },
    card_text: "Some quick example text"
  } do |options| %>
  <%= options[:card_text] %>
<% end %>

<% builder.define :card_action,
  defaults: {
    card_action_path: '#',
    card_action_text: 'Go somewhere',
    card_action_html: { class: "btn btn-primary" }
  } do |options| %>
  <%= link_to options[:card_action_text],
    options[:card_action_path],
    options[:card_action_html] %>
<% end %>

<% builder.define :card_content,
  with: :card_block %>

<%= builder.render :card %>
{% endhighlight %}

> The output from rendering this template will be the same as before

To round out the Bootstrap 4 Card template, we now specify each block definition that requires dynamic content in it's definition to take the options hash as a parameter. Any hardcoded context is then moved into the defaults hash for that block as an option and the Blocks gem will take. Where the hardcoded content previously was, we can now replace with dynamic code that utilizes the options hash that is passed in.

Now we have a more or less complete template (though lacking in several features described in the Bootstrap 4 documentation) for rendering and customizing Bootstrap 4 Cards.

### Rendering the Template with Option Overrides

```erb
<%= render_with_overrides partial: "shared/card",
  card_html: { id: "my-card" },
  card_action_text: "Go",
  card_action_html: { class: "btn btn-danger" },
  card_title: "My Title",
  card_text: "My Text",
  card_action_path: 'http://mobilecause.com',
  card_image: "my-image.png" %>
```

```haml
= render_with_overrides partial: "shared/card",
  card_html: { id: "my-card" },
  card_action_text: "Go",
  card_action_html: { class: "btn btn-danger" },
  card_title: "My Title",
  card_text: "My Text",
  card_action_path: 'http://mobilecause.com',
  card_image: "my-image.png"
```

```ruby
builder = Blocks::Builder.new(view_context,
  card_html: { id: "my-card" },
  card_action_text: "Go",
  card_action_html: { class: "btn btn-danger" },
  card_title: "My Title",
  card_text: "My Text",
  card_action_path: 'http://mobilecause.com',
  card_image: "my-image.png")
builder.render partial: "shared/card"
```

> The above code will output the following:

```html
<div class="card" id="my-card">
  <img class="card-img-top"
    src="/images/my-image.png"
    alt="My image" />

  <div class="card-block">
    <h4 class="card-title">
      My Title
    </h4>
    <p class="card-text">
      My Text
    </p>
    <a class="btn btn-danger"
      href="http://mobilecause.com">
      Go
    </a>
  </div>
</div>
```

Now that the template is defined, we can start rendering it with actual overrides. Since many of the blocks had some of their options defined as defaults, they can easily be overridden by the render_with_overrides options.

<aside class="warning">
  When calling the #render_with_overrides helper method from the view, any options that are passed in when automatically be passed to a new instance of a Blocks::Builder as init options. Therefore, if you're the one initializing the Blocks::Builder object (as is demonstrated in the Ruby example to the right), the options will need to be specified to the Blocks::Builder#new method instead of to the subsequent render_with_overrides call on the Blocks::Builder instance. This will likely be fixed in future releases.
</aside>

<aside class="notice">
  Notice also that the wrapper div maintained both the default class and the provided style. This is because the card_html options were deep merged and there was no clash in keys.
</aside>

### Rendering the Template with Block Overrides

```erb
<%= render_with_overrides partial:
  "shared/card" do |builder| %>
  <% builder.define :card do %>
    I am a complete replacement for the card
  <% end %>
<% end %>

<%= render_with_overrides partial:
  "shared/card" do |builder| %>
  <%# Change card_title's tag to h2 %>
  <% builder.define :card_title,
    wrapper_tag: :h2,
    card_title: "I had my wrapper tag changed" %>

  <%# Change card_action's definition completely %>
  <% builder.define :card_action do |options| %>
    <button onclick="alert('clicked');">
      <%= options[:card_action_text] %>
    </button>
  <% end %>
  <%# turn off card_text's wrapper %>
  <%#  and change it's definition %>
  <% builder.define :card_text, wrapper: nil do %>
    This is custom card text.
  <% end %>
<% end %>
```

```haml
= render_with_overrides partial: "shared/card" do |builder|
  - builder.define :card do
    I am a complete replacement for the card

= render_with_overrides partial: "shared/card" do |builder|
  -# Change card_title's tag to h2
  - builder.define :card_title,
    wrapper_tag: :h2,
    card_title: "I had my wrapper tag changed"

  -# Change card_action's definition completely
  - builder.define :card_action do |options|
    %button{onclick: "alert('clicked');"}
      = options[:card_action_text]
  -# turn off card_text's wrapper
  -#  and change it's definition
  - builder.define :card_text,
    wrapper: nil do
    This is custom card text.
```

```ruby
builder = Blocks::Builder.new(view_context)
text = builder.render partial:
  "shared/card" do |builder|
  builder.define :card do
    "I am a complete replacement for the card"
  end
end

builder = Blocks::Builder.new(view_context)
text2 = builder.render partial:
  "shared/card" do |builder|
  # Change card_title's tag to h2
  builder.define :card_title,
    wrapper_tag: :h2,
    card_title: "I had my wrapper tag changed"

  # Change card_action's definition completely
  builder.define :card_action do |options|
    %%"<button onclick='alert('clicked');'>
      #{options[:card_action_text]}
    </button>%.html_safe
  end
  # turn off card_text's wrapper
  #  and change it's definition
  builder.define :card_text, wrapper: nil do
    "This is custom card text."
  end
end
text + text2
```

> The above code will output the following:

```html
<div class="card">
  I am a complete replacement for the card
</div>
<div class="card">
  <img class="card-img-top"
    src="/assets/placeholder.jpg"
    alt="Placeholder">
  <div class="card-block">
    <h2 class="card-title">
      I had my wrapper tag changed
    </h2>
    This is custom card text.
    <button onclick="alert('clicked');">
      Go somewhere
    </button>
  </div>
</div>
```

Finding the option overrides aren't enough? There's always block overrides. Any block defined within the template can be overridden by an overrides block that executes before the template is rendered.

### Hooking and Skipping Template Definitions

> The following code would be added to /app/views/shared/\_card.html.erb, just before the builder.render :card call:

{% highlight erb %}
<% builder.define :card_subtitle,
  wrapper: :block_wrapper,
  wrapper_option: :card_subtitle_html,
  wrapper_tag: :h6,
  defaults: {
    card_subtitle_html: {
      class: "card-subtitle mb-2 text-muted"
    },
    card_subtitle: "Card subtitle"
  } do |options| %>
  <%= options[:card_subtitle] %>
<% end %>

<% builder.define :card_list_group,
  wrapper: :block_wrapper,
  wrapper_option: :card_list_group_html,
  wrapper_tag: :ul,
  defaults: {
    card_list_group_html: {
      class: "list-group list-group-flush"
    }
  } %>

<% builder.define :card_list_group_item,
  wrapper: :block_wrapper,
  wrapper_option: :card_list_group_item_html,
  wrapper_tag: :li,
  defaults: {
    card_list_group_item_html: {
      class: "list-group-item"
    },
    card_list_group_item: "Item"
  } do |options| %>
  <%= options[:card_list_group_item] %>
<% end %>

<% builder.define :card_header,
  wrapper: :block_wrapper,
  wrapper_option: :card_header_html,
  defaults: {
    card_header_html: {
      class: "card-header"
    },
    card_header: "Card Header"
  } do |options| %>
  <%= options[:card_header] %>
<% end %>

<% builder.define :card_footer,
  wrapper: :block_wrapper,
  wrapper_option: :card_footer_html,
  defaults: {
    card_footer_html: {
      class: "card-footer"
    },
    card_footer: "Card Footer"
  } do |options| %>
  <%= options[:card_footer] %>
<% end %>
{% endhighlight %}

```erb
<%= render_with_overrides partial:
  "shared/card" do |builder| %>
  <% builder.skip :card_image %>
  <% builder.after :card_title do %>
    <%= builder.render :card_subtitle %>
  <% end %>
  <% builder.prepend :card do %>
    <%= builder.render :card_header %>
  <% end %>
  <% builder.append :card do %>
    <%= builder.render :card_footer %>
  <% end %>
  <% builder.define :card_content,
    with: :card_list_group %>
  <% builder.append :card_content do %>
    <%= builder.render :card_list_group_item,
      card_list_group_item: "Item 1" %>
  <% end %>

  <% builder.prepend :card_content do %>
    <%= builder.render :card_list_group_item,
      card_list_group_item: "Item 0" %>
  <% end %>
<% end %>
```

```haml
= render_with_overrides partial: "shared/card" do |builder|
  - builder.skip :card_image
  - builder.after :card_title do
    = builder.render :card_subtitle
  - builder.prepend :card do
    = builder.render :card_header
  - builder.append :card do
    = builder.render :card_footer
  - builder.define :card_content,
    with: :card_list_group
  - builder.append :card_content do
    = builder.render :card_list_group_item,
      card_list_group_item: "Item 1"
  - builder.prepend :card_content do
    = builder.render :card_list_group_item,
      card_list_group_item: "Item 0"
```

```ruby
builder = Blocks::Builder.new(view_context)
builder.render partial:
  "shared/card" do |builder|
  builder.skip :card_image
  builder.after :card_title do
    builder.render :card_subtitle
  end
  builder.prepend :card do
    builder.render :card_header
  end
  builder.append :card do
    builder.render :card_footer
  end
  builder.define :card_content,
    with: :card_list_group
  builder.append :card_content do
    builder.render :card_list_group_item,
      card_list_group_item: "Item 1"
  end

  builder.prepend :card_content do
    builder.render :card_list_group_item,
      card_list_group_item: "Item 0"
  end
end
```

> The above code will output the following:

```html
<div class="card">
  <div class="card-header">
    Card Header
  </div>
  <ul class="list-group list-group-flush">
    <li class="list-group-item">
      Item 0
    </li>
    <li class="list-group-item">
      Item 1
    </li>
  </ul>
  <div class="card-footer">
    Card Footer
  </div>
</div>
```
Scanning through the Bootstrap 4 Cards documentation, it can be plainly observed that the current card template only scratches the surface of available features for cards. In the code to the right, a few of these features are added to the template: :card_subtitle, :card_list_group with :card_list_group_item's, :card_header, and :card_footer. Though all of these features are defined as blocks, none of them are actually used by default. This is actually a good approach, in that these additional features can be added or swapped in as desired while the default output will be unaffected.

We also have access to the full arsenal of hooks, wrapper with relation to the various block definitions within the template. We can also skip blocks or replace the definitions with new definitions.

### Extending the Template

> Assume the following partial exists in /app/views/shared/\_team_card.html.erb:

{% highlight erb %}
<%= builder.render partial:
  "shared/card" do |builder| %>
  <% builder.define :card_title,
    card_title: team.name %>
  <% builder.define :card_text,
    card_text: team.description %>
  <% builder.define :card_action,
    card_action_text: 'Donate' %>
<% end %>
{% endhighlight %}

> Then when the following code runs:

```erb
<% team = OpenStruct.new(
  name: "Andrew's Campaign",
  npo: "Innogive",
  description: "Donate money"
) %>
<%= render_with_overrides partial:
  "shared/team_card",
  team: team do |builder| %>
  <% builder.after :card_title,
    with: :card_subtitle,
    card_subtitle: team.npo %>
<% end %>
```

```haml
- team = OpenStruct.new(name: "Andrew's Campaign",
  npo: "Innogive",
  description: "Donate money")
= render_with_overrides partial: "shared/team_card",
  team: team do |builder|
  - builder.after :card_title do
    = builder.render :card_subtitle,
      card_subtitle: team.npo
```

```ruby
team = OpenStruct.new(
  name: "Andrew's Campaign",
  npo: "Innogive",
  description: "Donate money"
)
builder = Blocks::Builder.new(view_context)
builder.render partial:
  "shared/team_card",
  team: team do |builder|
    builder.after :card_title do
      builder.render :card_subtitle,
        card_subtitle: team.npo
    end
end
```

> It will produce the following output:

```html
<div class="card">
  <img class="card-img-top"
    src="/assets/placeholder.jpg"
    alt="Placeholder">
  <div class="card-block">
    <h4 class="card-title">
      Andrew's Campaign
    </h4>
    <h6 class="card-subtitle mb-2 text-muted">
      Innogive
    </h6>
    <p class="card-text">
      Donate money
    </p>
    <a class="btn btn-primary" href="#">
      Donate
    </a>
  </div>
</div>
```

Templates may also be extended to form new templates, which may also be extended as many times as necessary.

An example might be create new templates that render different versions of a card. For example, maybe one type of card is detailed, while another is an overview. Or maybe one type of card displays information about a team and another about an organization. Or maybe one is meant for conveying information on a dashboard while the other in meant purely for frontend pages. Perhaps then the dashboard card template could be extended multiple times as well to represent different types of objects that may be displayed on the dashboard.

In the example to the right, a team-specific version of card is created as a template. Code then renders this new template with some overrides of if its own. The overrides have been kept very basic in order to clearly demonstrate how to setup a template that extends another template.

<aside class="warning">
  Take note that with the team_card template, builder.render is used instead of render_with_overrides. This is forcing the two templates to render using the same Blocks::Builder instance, i.e. to share a Blocks namespace. This is what allows the overrides block for the team_card template to affect the defaults in card template.
</aside>
