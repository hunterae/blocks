# Rendering Blocks

```erb
<%= blocks.render :my_block %>
```

```haml
= blocks.render :my_block
```

```ruby
# where builder is an instance of Blocks::Builder
builder.render :my_block
```

Whether you define the Block using a Ruby block, Rails Partial, or a Proxy to another Block, the method of rendering that block of code is the same:

## Providing a Default Definition

If a block is rendered without a definition, it doesn't output anything, but it doesn't fail either:

```erb
<%= blocks.render :block_without_a_definition %>
```

This, in itself, is no different than running:

```erb
<%= yield :some_content_name_not_defined %>
```

Rails would handle this in exactly the same way, and in both examples, nothing was rendered, because a definition for the "block_without_a_definition" Block was never defined, just as content_for was never run to define "some_content_name_not_defined".

But with Blocks, we can actually specify what to render when no corresponding definition was made, and we can do this in the exact same three ways that Blocks are defined:

We can render with a default Ruby block to use:

```erb
<%= blocks.render :my_block_without_a_definition do %>
  This is my default definition for this Block
<% end %>
```

We can render with a default partial to use:

```erb
<%= blocks.render :my_block_without_a_definition, partial: "partial_to_render" %>
```

We can render with a default proxy to another Block to use:
```erb
<%= blocks.render :my_block_without_a_definition, with: :another_block %>
```

## With Runtime Options

TODO

## With a Collection

```erb
<% blocks.define :my_block do |item| %>
  <li>Item: <%= item %></li>
<% end %>

<ul>
  <%= blocks.render :my_block, collection: [1, 2, 3, 4] %>
</ul>
```

> The above command returns rendered HTML:

```html

```


Rendering a partial in Rails allows the developer to specify a collection, which will render the partial for each item in the collection. Likewise, Blocks has near-identical syntax for rendering a collection:

The collection may also be set when the Block is defined:

```erb
<% blocks.define :my_block, collection: [1, 2, 3, 4] do |item| %>
  Item: <%= item %>
<% end %>

<%= blocks.render :my_block %>

=> Item: 1 Item: 2 Item: 3 Item: 4
```

Additionally, you can set the "as" option which will affect the variable name of the item in the collection within the rendered partial:

```erb
<% blocks.define :my_block, collection: [1, 2, 3, 4], as: :item, partial: "my_partial"

<%= blocks.render :my_block %>

=> Will render each _my_partial for each item in the collection. _my_partial will have item set to the item of the collection.
```

## With Additional Parameters

Moving on to another key difference, Blocks may be defined with params, and params may be passed to Blocks when they are rendered:

```erb
<% blocks.define :my_block do |param1, param2, options| %>
  Hello <%= param1 %>. My second param is <%= param2 %> and my options are <%= options.inspect %>
<% end %>

<%= blocks.render :my_block, "World", "param2", a: 1, b: 2, c: 3 %>

=> Outputs Hello World. My second param is param2 and my options are {"a"=>1, "b"=>2, "c"=>3}
```

The number of parameters do not need to match up between the define and render call, so the defined block may take no arguments or more arguments than the render call passes.

There is a second way of passing parameters to a Block - on the define call itself:

```erb
<% blocks.define :my_block, a: 1, b: 2, c: 3 do |options| %>
  My options are <%= options.inspect %>
<% end %>

<%= blocks.render :my_block %>

=> My options are {"a"=>1, "b"=>2, "c"=>3}
```

Any parameters that have matching names between the define and the render calls will give precedence to the render parameters:

```erb
<% blocks.define :my_block, a: 1, b: 2, c: 3 do |options| %>
  My options are <%= options.inspect %>
<% end %>

<%= blocks.render :my_block, a: 4, c: 6 %>

=> My options are {"a"=>4, "c"=>6, "b"=>2}
```