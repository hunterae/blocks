Rendering a partial in Rails allows the developer to specify a collection, which will render the partial for each item in the collection. Likewise, Blocks has near-identical syntax for rendering a collection:

```erb
<% blocks.define :my_block do |item| %>
  Item: <%= item %>
<% end %>

<%= blocks.render :my_block, collection: [1, 2, 3, 4] %>

=> Item: 1 Item: 2 Item: 3 Item: 4
```

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