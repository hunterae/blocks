If a block is rendered without a definition, it doesn't output anything, but it doesn't fail either:

```erb
<%= blocks.render :block_without_a_definition %>
```

This, in itself, is no different than running:

```erb
<%= yield :some_content_name_not_defined %>
```

Rails would handle this in exactly the same way, and in both examples, nothing was rendered, because a definition for the "block_without_a_definition" Block was never defined, just as content_for was never run to define "some_content_name_not_defined".

But with Blocks, we can actually specify what to do when no corresponding definition was made, and we can do this in the exact same three ways that Blocks can be defined:

We can render with a default block to use:

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