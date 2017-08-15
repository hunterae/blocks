With Blocks, you can define a Block of code for later rendering using 3 different strategies. Rendering that Block of code is done with the same call for each strategy.

{% include responsive_image.html link="assets/images/BlockRendering.png" %}

### Strategy 1 - Defining with a Ruby Block

A Block may be defined as a standard Ruby block (which may be a Ruby Block, Proc, or Lambda):

```erb
<% blocks.define :my_block do %>
  The content of my block
<% end %>
```

### Strategy 2 - Defining with a Rails Partial

A Block may be defined as a Rails partial; whenever the Block gets rendered, the partial actually gets rendered.

```erb
<%= blocks.define :my_block, partial: "my_partial" %>
```

### Strategy 3 - Defining with a Proxy to Another Block

A Block may be defined as a proxy to another block using the with keyword in the parameters.

```erb
<% blocks.define :my_block, with: :some_proxy_block %>
```

Proxy Blocks can also be chained together though separate definitions. The order of Block definitions is irrelevant, so long as they all occur before the Block is rendered.

```erb
<% blocks.define :my_block, with: :some_proxy_block %>
<% blocks.define :some_proxy_block, with: :some_other_proxy_block %>
<% blocks.define :some_other_proxy_block do %>
  My proxied proxied content
<% end %>
```

Likewise, the Block that another Block proxies to can be defined in any of the three ways that Blocks are defined:

```erb
<% blocks.define :my_block, with: :some_proxy_block %>

<!-------------- AS A BLOCK ------------------->
<% blocks.define :some_proxy_block do %>
  My proxy block definition
<% end %>

<!----------- OR AS A PARTIAL ----------------->
<% blocks.define :some_other_proxy_block, partial: "some_partial" %>

<!------- OR AS ANOTHER PROXY ----------------->
<% blocks.define :some_other_proxy_block, with: :yet_some_other_proxy_block %>
```

Also, a Proxy block can point to a method on the builder instance (by default, this is an instance of Blocks::Builder).

### 1 Render Call

Whether you define the Block using a Ruby block, Rails Partial, or a Proxy to another Block, the method of rendering that block of code is the same:

```erb
<%= blocks.render :my_block %>
```