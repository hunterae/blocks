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