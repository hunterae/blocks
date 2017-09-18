# Skipping Blocks

> Prerequisite code for below examples:

```erb
<% blocks.define :my_block,
  wrap_all: :wrap_all_wrapper,
  wrap_each: :wrap_each_wrapper,
  wrap_with: :wrap_with_wrapper do %>
  My Block
  <br>
<% end %>

<% blocks.define :proxy_block do |*args| %>
  <% options = args.extract_options! %>
  <% item = args.shift %>
  <%= options[:name] %>
  <br>
<% end %>

<% blocks.define :wrapper do |b, *args| %>
  <% options = args.extract_options! %>
  <% item = args.shift %>
  <%= options[:name] %> Before
  <br>
  <%= b.call %>
  <%= options[:name] %> After
  <br>
<% end %>

<% blocks.define :wrap_all_wrapper,
  name: "wrap_all Wrapper",
  with: :wrapper %>

<% blocks.define :wrap_each_wrapper,
  name: "wrap_each Wrapper",
  with: :wrapper %>

<% blocks.define :wrap_with_wrapper,
  name: "wrap_with Wrapper",
  with: :wrapper %>

<% [:before_all,
    :before,
    :prepend,
    :append,
    :after,
    :after_all].each do |hook| %>
  <% blocks.send(hook,
      :my_block,
      with: :proxy_block,
      name: "\"#{hook}\" Hook") %>
<% end %>

<% [:around_all,
    :around,
    :surround].each do |hook| %>
  <% blocks.send(hook,
      :my_block,
      with: :wrapper,
      name: "\"#{hook}\" Hook") %>
<% end %>
```

```haml
- blocks.define :my_block,
  wrap_all: :wrap_all_wrapper,
  wrap_each: :wrap_each_wrapper,
  wrap_with: :wrap_with_wrapper do
  My Block
  %br

- blocks.define :proxy_block do |*args|
  - options = args.extract_options!
  - item = args.shift
  = options[:name]
  %br

- blocks.define :wrapper do |b, *args|
  - options = args.extract_options!
  - item = args.shift
  = options[:name]
  Before
  %br
  = b.call
  = options[:name]
  After
  %br

- blocks.define :wrap_all_wrapper,
  name: "wrap_all Wrapper",
  with: :wrapper

- blocks.define :wrap_each_wrapper,
  name: "wrap_each Wrapper",
  with: :wrapper

- blocks.define :wrap_with_wrapper,
  name: "wrap_with Wrapper",
  with: :wrapper

- [:before_all,
   :before,
   :prepend,
   :append,
   :after,
   :after_all].each do |hook|
  - blocks.send(hook,
      :my_block,
      with: :proxy_block,
      name: "\"#{hook}\" Hook")

- [:around_all,
   :around,
   :surround].each do |hook|
  - blocks.send(hook,
      :my_block,
      with: :wrapper,
      name: "\"#{hook}\" Hook")
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.define :my_block,
  wrap_all: :wrap_all_wrapper,
  wrap_each: :wrap_each_wrapper,
  wrap_with: :wrap_with_wrapper do
  "My Block<br>".html_safe
end

builder.define :proxy_block do |*args|
  options = args.extract_options!
  item = args.shift
  "#{options[:name]}<br>".html_safe +
end

builder.define :wrapper do |b, *args|
  options = args.extract_options!
  item = args.shift
  "#{options[:name]} Before<br>".html_safe +
  b.call +
  "#{options[:name]} After<br>".html_safe +
end

builder.define :wrap_all_wrapper,
  name: "wrap_all Wrapper",
  with: :wrapper

builder.define :wrap_each_wrapper,
  name: "wrap_each Wrapper",
  with: :wrapper

builder.define :wrap_with_wrapper,
  name: "wrap_with Wrapper",
  with: :wrapper

[:before_all,
 :before,
 :prepend,
 :append,
 :after,
 :after_all].each do |hook|
  builder.send(hook,
    :my_block,
    with: :proxy_block,
    name: "\"#{hook}\" Hook")
end

[:around_all,
 :around,
 :surround].each do |hook|
  builder.send(hook,
    :my_block,
    with: :wrapper,
    name: "\"#{hook}\" Hook")
end
```

Blocks may be skipped from rendering, such that whenever a render call occurs, no content will be rendered.

<aside class="notice">
  The code to the right is prerequistive code to the "Skipping Blocks" examples that follow
</aside>

Skips come in two forms: skipping a block only, and skipping a block with all of its hooks and wrappers.

## Skipping the Block Only

```erb
<h2>Render Before Skip:</h2>
<%= blocks.render :my_block %>

<% blocks.skip :my_block %>
<h2>Render After Skip:</h2>
<%= blocks.render :my_block %>
```

```haml
%h2 Render Before Skip:
= blocks.render :my_block

- blocks.skip :my_block
%h2 Render After Skip:
= blocks.render :my_block
```

```ruby
output =
  "<h2>Render Before Skip:</h2>".
    html_safe +
  builder.render :my_block

builder.skip :my_block
output +=
  "<h2>Render After Skip:</h2>".
    html_safe +
  builder.render :my_block
output
```

> The above code will output the following:

```
Render Before Skip:

"before_all" Hook
"around_all" Hook Before
wrap_all Wrapper Before
wrap_each Wrapper Before
"around" Hook Before
"before" Hook
wrap_with Wrapper Before
"surround" Hook Before
"prepend" Hook
My Block
"append" Hook
"surround" Hook After
wrap_with Wrapper After
"after" Hook
"around" Hook After
wrap_each Wrapper After
wrap_all Wrapper After
"around_all" Hook After
"after_all" Hook

Render After Skip:

"before_all" Hook
"around_all" Hook Before
wrap_all Wrapper Before
wrap_each Wrapper Before
"around" Hook Before
"before" Hook
"after" Hook
"around" Hook After
wrap_each Wrapper After
wrap_all Wrapper After
"around_all" Hook After
"after_all" Hook
```

A block may be skipped using the #skip method.

Calling #skip has the effect of skipping rendering of the block itself, and any "prepend" hooks, "append" hooks, "surround" hooks, and the "wrap_with" wrapper that might have been associated with the block being skipped.

Any "before" hooks, "before_all" hooks, "after" hooks, "after_all" hooks, "around" hooks, "around_all" hooks, the "wrap_all" wrapper, and the "wrap_each" wrapper will continue to be rendered when the block is skipped. See [Skipping the Block and its Hooks](#Skipping the Block and its Hooks) for skipping everything.

### With a Collection

```erb
<% blocks.define :my_block,
  collection: ["a", "b"] %>

<h2>Render Before Skip:</h2>
<%= blocks.render :my_block %>

<% blocks.skip :my_block %>
<h2>Render After Skip:</h2>
<%= blocks.render :my_block %>
```

```haml
- blocks.define :my_block,
    collection: ["a", "b"]

%h2 Render Before Skip:
= blocks.render :my_block

- blocks.skip :my_block
%h2 Render After Skip:
= blocks.render :my_block
```

```ruby
output =
  "<h2>Render Before Skip:</h2>".
    html_safe +
  builder.render :my_block

builder.skip :my_block
output +=
  "<h2>Render After Skip:</h2>".
    html_safe +
  builder.render :my_block
output
```

> The above code will output the following:

```
Render Before Skip:

"before_all" Hook
"around_all" Hook Before
wrap_all Wrapper Before
wrap_each Wrapper Before for item "a"
"around" Hook Before for item "a"
"before" Hook for item "a"
wrap_with Wrapper Before for item "a"
"surround" Hook Before for item "a"
"prepend" Hook for item "a"
My Block
"append" Hook for item "a"
"surround" Hook After for item "a"
wrap_with Wrapper After for item "a"
"after" Hook for item "a"
"around" Hook After for item "a"
wrap_each Wrapper After for item "a"
wrap_each Wrapper Before for item "b"
"around" Hook Before for item "b"
"before" Hook for item "b"
wrap_with Wrapper Before for item "b"
"surround" Hook Before for item "b"
"prepend" Hook for item "b"
My Block
"append" Hook for item "b"
"surround" Hook After for item "b"
wrap_with Wrapper After for item "b"
"after" Hook for item "b"
"around" Hook After for item "b"
wrap_each Wrapper After for item "b"
wrap_all Wrapper After
"around_all" Hook After
"after_all" Hook

Render After Skip:

"before_all" Hook
"around_all" Hook Before
wrap_all Wrapper Before
wrap_each Wrapper Before for item "a"
"around" Hook Before for item "a"
"before" Hook for item "a"
"after" Hook for item "a"
"around" Hook After for item "a"
wrap_each Wrapper After for item "a"
wrap_each Wrapper Before for item "b"
"around" Hook Before for item "b"
"before" Hook for item "b"
"after" Hook for item "b"
"around" Hook After for item "b"
wrap_each Wrapper After for item "b"
wrap_all Wrapper After
"around_all" Hook After
"after_all" Hook
```

A block with a collection can also be skipped, though the resulting output may not be desired.

Calling #skip on a block with a collection has the effect of skipping rendering of the block itself, and any "prepend" hooks, "append" hooks, "surround" hooks, and the "wrap_with" wrapper that might have been associated with the block being skipped.

Any "before" hooks, "before_all" hooks, "after" hooks, "after_all" hooks, "around" hooks, "around_all" hooks, the "wrap_all" wrapper, and the "wrap_each" wrapper will continue to be rendered when the block is skipped. All the hooks and wrappers, with the exception of the "around_all", "wrap_all", "before_all", and "after_all" ones, will be rendered for each item in the collection (this behavior will likely change in a future release of Blocks).

See [Skipping the Block and its Hooks](#Skipping the Block and its Hooks) for skipping everything.

## Skipping the Block and its Hooks

```erb
<% blocks.skip_completely :my_block %>
<%= blocks.render :my_block do %>
  Hello
<% end %>
```

```haml
- blocks.skip_completely :my_block
= blocks.render :my_block do
  Hello
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.skip_completely :my_block
builder.render :my_block do
  "Hello"
end
```

> There will be no output from the above command

Because calling #skip can still have the effect of rendering some of the hooks and wrappers for a particular block (before, after, around, before_all, after_all, wrap_all, wrap_each will still be rendered), there is the need for a second type of skip, called #skip_completely, which will skip the block and all associated hooks and wrappers.