# Rendering Blocks

```erb
<%= blocks.render :my_block %>
<!-- OR -->
<%= blocks.render "my_block" %>
```

```haml
= blocks.render :my_block
#- OR
= blocks.render "my_block"
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.render :my_block
# OR
builder.render "my_block"
```

There is a single method to render a block that has been defined, regardless of that block's rendering strategy (whether it's a Ruby block, Rails partial, or a proxy to another block).

The name of the block being rendered can be a symbol or a string. The underlying system treats symbols and strings the same. Therefore, any block that is defined with a String name can be rendered with its corresponding symbol name and vice-versa.

<img src="{{'/render_strategies.png' | prepend: site.images_dir | prepend: '/'}}" />

## With no Corresponding Definition

If a block is rendered without a definition, it doesn't output anything (unless there are hooks or wrappers for the specified block), but it doesn't fail either.

## With a Default Definition

Blocks provides the ability to specify a default definition for the block should no corresponding definition be found.

<aside class="warning">
The default definition is not stored. It is used for the render call to which it is applied and then thrown away.
</aside>

### With a Ruby Block

```erb
<%= blocks.render :my_block do %>
  content
<% end %>

<!-- OR -->

<% my_block = Proc.new { "content" } %>
<%= blocks.render :my_block,
  &my_block %>

<!-- OR -->

<% my_block = Proc.new { "content" } %>
<%= blocks.render :my_block,
  defaults: { block: my_block } %>
```

```haml
= blocks.render :my_block do
  content

-# OR

- my_block = Proc.new { "content" }
= blocks.render :my_block, &my_block

-# OR

- my_block = Proc.new { "content" }
= blocks.render :my_block,
  defaults: { block: my_block }
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.render :my_block do
  "content"
end

# OR

my_block = Proc.new { "content" }
builder.render :my_block, &my_block

# OR

my_block = Proc.new { "content" }
builder.render :my_block,
  defaults: { block: my_block }
```

> After running the above code, the output will be:

```
content
```

The default definition can be specified as a Ruby block:

<aside class="notice">
  Just as a block can be defined with a Ruby block that takes an optional "options" parameter, default definitions can also take an options parameter.
</aside>

### With a Rails Partial

```erb
<%= blocks.render :my_block,
  defaults: { partial: "my_partial" } %>
```

```haml
= blocks.render :my_block,
  defaults: { partial: "my_partial" }
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.render :my_block,
  defaults: { partial: "my_partial" }
```

> After running the above code, the output will be whatever the result is of rendering the partial "my_partial"

The default definition can be specified as a Rails partial:

### With a Proxy to Another Block

```erb
<%= blocks.render :my_block,
  defaults: { with: :proxy_block } %>
```

```haml
= blocks.render :my_block,
  defaults: { with: :proxy_block }
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.render :my_block,
  defaults: { with: :proxy_block }
```

> After running the above code, the output will be whatever the result is of rendering the Proxy block or method called "some_other_block"

The default definition can be specified as a proxy to another block:

## With Options

```erb
<%= blocks.render :my_block,
  defaults: {
    a: "defaults",
    b: "defaults"
  },
  a: "runtime",
  c: "runtime" do |options| %>
  <%= options.to_json %>
<% end %>
```

```haml
= blocks.render :my_block,
  defaults: { a: "defaults",
              b: "defaults" },
  a: "runtime",
  c: "runtime" do |options|
  = options.to_json
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.render :my_block,
  defaults: {
    a: "defaults",
    b: "defaults"
  },
  a: "runtime",
  c: "runtime" do |options|
  options.to_json
end
```

> The output would be:

```json
{
  "a":"runtime",
  "c":"runtime",
  "b":"defaults"
}
```

Just as options can be set for a block when the block is defined, they can also be applied at render.

Options provided to the render call can be either runtime options or default options (unlike defining blocks, there is no concept for render standard options).

Default options are specified within a nested hash under the key "defaults".

All other options are considered to be runtime options. Runtime options provided to the render call will take precedence over all other options, including runtime options set on the block definition.

### Indifferent Access

```erb
<% blocks.define :my_block,
  "a" => "Block String",
  b: "Block Symbol" %>
<%= blocks.render :my_block,
  a: "Runtime Symbol" do |options| %>
  <%= options.to_json %>
<% end %>
```

```haml
- blocks.define :my_block,
  "a" => "Block String",
  b: "Block Symbol"
= blocks.render :my_block,
  a: "Runtime Symbol" do |options|
  = options.to_json
```

```ruby
# where builder is an instance of
#  Blocks::Builder
builder.define :my_block,
  "a" => "Block String",
  b: "Block Symbol"
builder.render :my_block,
  a: "Runtime Symbol" do |options|
  options.to_json
end
```

> The output would be:

```json
{
  "a":"Runtime Symbol",
  "b":"Block Symbol"
}
```

> Note that the render options took precedence over the block options. This is because render options are treated as runtime options (unless they are wrapper inside of the defaults hash) which take the highest level of precedence when merging options.

Like the name of the block itself, the options hash does not care whether a symbol or a string is provided as a hash key; they are treated the same.

### Deep Merging of Options

```erb
<% blocks.define :my_block,
  a: 1,
  shared_key: {
    a: "a1",
    c: "c1"
  } %>
<%= blocks.render :my_block,
  b: 1,
  shared_key: {
    a: "a2",
    b: "b1"
  } do |options| %>
  <%= options.to_json %>
<% end %>
```

```haml
- blocks.define :my_block,
             a: 1,
    shared_key: { a: "a1",
                  c: "c1"}
= blocks.render :my_block,
             b: 1,
    shared_key: { a: "a2",
                  b: "b1" } do |options|
  = options.to_json
```

```ruby
# where builder is an instance of
#  Blocks::Builder
builder.define :my_block,
  a: 1,
  shared_key: {
    a: "a1",
    c: "c1"
  }
builder.render :my_block,
  b: 1,
  shared_key: {
    a: "a2",
    b: "b1"
  } do |options|
  options.to_json
end
```

> The output would be:

```json
{
  "b":1,
  "shared_key": {
    "a":"a2",
    "c":"c1",
    "b":"b1"
  },
  "a":1
}
```

When the block definition and the render options share a duplicate key with hashes as their values, they are deep merged, giving precedence for duplicate nested keys to the render options.

## With Parameters

```erb
<% blocks.define :my_block do |param_1, param_2, param_3, param_4| %>
  Param 1: <%= param_1.inspect %>
  <br>
  Param 2: <%= param_2.inspect %>
  <br>
  Param 3: <%= param_3.inspect %>
  <br>
  Param 4: <%= param_4.inspect %>
  <br>
<% end %>

Without a Collection:
<br>
<%= blocks.render :my_block,
  "foo", "bar", a: 1, b: 2 %>
<br>
With a Collection:
<br>
<%= blocks.render :my_block,
  "foo", "bar", a: 1, b: 2,
  collection: ["Item1", "Item2"] %>
```

```haml
- blocks.define :my_block do |param_1,
    param_2, param_3, param_4|
  Param 1:
  = param_1.inspect
  %br
  Param 2:
  = param_2.inspect
  %br
  Param 3:
  = param_3.inspect
  %br
  Param 4:
  = param_4.inspect
  %br

Without a Collection:
%br
= blocks.render :my_block,
  "foo", "bar", a: 1, b: 2
%br
With a Collection:
%br
= blocks.render :my_block,
  "foo", "bar", a: 1, b: 2,
  collection: ["Item1", "Item2"]
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.define :my_block do |param_1,
    param_2, param_3, param_4|
  "Param 1: #{param_1.inspect}<br>".html_safe +
  "Param 2: #{param_2.inspect}<br>".html_safe +
  "Param 3: #{param_3.inspect}<br>".html_safe +
  "Param 4: #{param_4.inspect}".html_safe +
end

"Without a Collection:<br>".html_safe +
builder.render(:my_block,
  "foo", "bar", a: 1, b: 2) +
"<br>With a Collection:<br>".html_safe +
builder.render(:my_block,
  "foo", "bar", a: 1, b: 2,
  collection: ["Item1", "Item2"])
```

> This will produce the following output

```
Without a Collection:
Param 1: "foo"
Param 2: "bar"
Param 3: {"a"=>1, "b"=>2}
Param 4: nil

With a Collection:
Param 1: "Item1"
Param 2: "foo"
Param 3: "bar"
Param 4: {"a"=>1, "b"=>2, "object"=>"Item1", "current_index"=>0}
Param 1: "Item2"
Param 2: "foo"
Param 3: "bar"
Param 4: {"a"=>1, "b"=>2, "object"=>"Item2", "current_index"=>1}
```

Blocks are also capable of taking additional parameters besides potentially the options and the item if a collection is being rendered.

Though this concept is still relatively limited in its potential uses at this time (and some additional use cases probably still need to be hammered out), it can be used to pass an arbitrary number of additional parameters to a defined block.

At this time, this will not do anything meaningful if the Block is defined to render a partial. However, if the Block is defined to be a Ruby block or a Proxy to a Block defined with a Ruby block, Blocks will attempt to match up the number of arguments the block expects with the number of arguments that could be sent to it from the render call.

Remember, options will always be the last argument, and if rendering a collection, item will be the first. Any additional params passed to the render call will then be sent as the second argument onward, followed by the options hash. However, if fewer arguments are expected by the block than are sent, Blocks will send the lesser number of arguments.

See the example to the right to make better sense out of what is being explained here.

<aside class="notice">
  Take note that passing a collection into the render call changes the first parameter to the block to the item in the collection and shifts the rest of the arguments over.
</aside>

## With a Collection

```erb
<ul>
<%= blocks.render :my_block,
  collection: [1, 2, 3, 4] do |item| %>
  <li>Item: <%= item %></li>
<% end %>
</ul>

<!-- OR -->

<%= blocks.define :my_block,
      collection: [1, 2, 3, 4] %>
<ul>
<%= blocks.render :my_block do |item| %>
  <li>Item: <%= item %></li>
<% end %>
</ul>
```

```haml
%ul
  = blocks.render :my_block,
    collection: [1, 2, 3, 4] do |item|
    %li= "Item: #{item}"

-# OR

- blocks.define :my_block,
  collection: [1, 2, 3, 4]
%ul
  = blocks.render :my_block do |item|
    %li= "Item: #{item}"
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.content_tag :ul do
  builder.render :my_block,
    collection: [1, 2, 3, 4] do |item|
    builder.content_tag :li,
      "Item #{item}"
  end
end

# OR

builder.define :my_block,
  collection: [1, 2, 3, 4]
builder.content_tag :ul do
  builder.render :my_block do |item|
    builder.content_tag :li,
      "Item #{item}"
  end
end
```

> The output would be:

```html
<ul>
  <li>Item: 1</li>
  <li>Item: 2</li>
  <li>Item: 3</li>
  <li>Item: 4</li>
</ul>
```

A collection may be defined when rendering a block, or it may have already been defined when the block was defined. When the block is rendered, it will actually render the block multiple times, once for each item in the collection.

<aside class="warning">
  Since render options take precedence over block options, if a collection is defined both on the block definition and passed to the render call, the collection provided to the render call will be given precedence.
</aside>

<aside class="warning">
When the block definition is a Ruby block, the block should be prepared to take each item from the collection as its first parameter.
</aside>


### With an Alias

```erb
<ul>
  <%= blocks.render :my_block,
        collection: [1, 2, 3, 4],
        as: :card do |item, options| %>
    <li>
      Item: <%= item %>
      <br>
      Options: <%= options.to_hash %>
    </li>
  <% end %>
</ul>
```

```haml
%ul
  = blocks.render :my_block,
    collection: [1, 2, 3, 4],
    as: :card do |item, options|
    %li
      ="Item: #{item}"
      %br
      ="Options: #{options.to_hash}"
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.content_tag :ul do
  builder.render :my_block,
    collection: [1, 2, 3, 4],
    as: :card do |item, options|
    builder.content_tag :li do
      "Item #{item}" +
      "<br>".html_safe +
      "Options: #{options.to_hash}"
    end
  end
end
```

> The output would be:

```html
<ul>
  <li>
    Item: 1
    <br>
    Options: {
      "card"=>1,
      "current_index"=>0
    }
  </li>
  <li>
    Item: 2
    <br>
    Options: {
      "card"=>2,
      "current_index"=>1
    }
  </li>
  <li>
    Item: 3
    <br>
    Options: {
      "card"=>3,
      "current_index"=>2
    }
  </li>
  <li>
    Item: 4
    <br>
    Options: {
      "card"=>4,
      "current_index"=>3
    }
  </li>
</ul>
```

Additionally, you can set an alias for each item in the collection as the collection is iterated over. This is done using the "as" option.

If the block being rendered is a partial, it will alias each item in the collection with the specified option (i.e. the value of the "as" option will become the name of the variable available in the partial being rendered and will contain each item in the collection being rendered). Additionally, "current_index" will also be a variable that can be accessed within the partial, and will correspond to the item's index in the collection.

If the block being rendered is not a partial, it will store the alias name as a key in an options hash that will be optionally passed to the block when it is rendered. Additionally, "current_index" will store the item's current index within the collection.

### Without an Alias

```erb
<ul>
<%= blocks.render :my_block,
  collection: [1, 2] do |i, options| %>
  <li>
    Item: <%= i %>
    <br>
    Options: <%= options.to_hash %>
  </li>
<% end %>
</ul>
```

```haml
%ul
  = blocks.render :my_block,
    collection: [1, 2] do |i, options|
    %li
      ="Item: #{i}"
      %br
      ="Options: #{options.to_hash}"
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.content_tag :ul do
  builder.render :my_block,
    collection: [1, 2] do |i, options|
    builder.content_tag :li do
      "Item #{i}" +
      "<br>".html_safe +
      "Options: #{options.to_hash}"
    end
  end
end
```

> The output would be:

```html
<ul>
  <li>
    Item: 1
    <br>
    Options: {
      "object"=>1,
      "current_index"=>0
    }
  </li>
  <li>
    Item: 2
    <br>
    Options: {
      "object"=>2,
      "current_index"=>1
    }
  </li>
</ul>
```

When no alias is specified and the block being rendered is a partial, it will alias each item in the collection as "object" (i.e. "object" will become the name of the variable available in the partial being rendered and will contain each item in the collection being rendered).
Additionally, "current_index" will also be a variable that can be accessed within the partial, and will correspond to the item's index in the collection.

If the block being rendered is not a partial, it will store "object" as a key in an options hash that will be optionally passed to the block when it is rendered. Additionally, "current_index" will store the item's current index within the collection.

## Without a Name

```erb
<!-- rendering a partial -->
<%= blocks.render partial:
  "a_partial" %>

<!-- with local options -->
<%= blocks.render a: 1, b: 2,
  partial: "a_partial" %>

<!-- and a collection -->
<%= blocks.render a: 1, b: 2,
  partial: "a_partial",
  collection: [1, 2, 3] %>

<!-- rendering with a proxy -->
<%= blocks.render with:
  :some_proxy %>
```

```haml
-# rendering a partial
= blocks.render partial: "a_partial"

-# with local options
= blocks.render partial: "a_partial",
  a: 1, b: 2

-# and a collection
= blocks.render partial: "a_partial",
  a: 1, b: 2, collection: [1, 2, 3]

-# rendering with a proxy
= blocks.render with: :some_proxy
```

```ruby
# where builder is an instance
#  of Blocks::Builder

# rendering a partial
builder.render partial: "a_partial"

# with local options
builder.render partial: "a_partial",
  a: 1, b: 2

# and a collection
builder.render partial: "a_partial",
  a: 1, b: 2, collection: [1, 2, 3]

# rendering with a proxy
builder.render with: :some_proxy
```

Blocks may be rendered without a block name.

This is usually done in combination with a wrapper, a proxy, or a partial.

Use this when you don't need corresponding hooks for the block to be rendered or when wanting to render a partial or a proxy block.
