<!-- Defining multiple blocks at once -->
## Multiple Blocks at Once

```haml
- namer = Proc.new {|i| "block #{i}" }
blocks.define_each ["a", 1, "b"],
  namer do |item|
  ="Hello from #{item}"
  &br

= blocks.render("block a")
= blocks.render("block 1")
= blocks.render("block b")
```

```ruby
# where builder is an instance of
#  Blocks::Builder
namer = Proc.new {|i| "block #{i}" }
builder.define_each ["a", 1, "b"],
  namer do |item|
  "Hello from #{item}<br>".html_safe
end

builder.render("block a") +
builder.render("block 1") +
builder.render("block b")
```

Multiple different blocks may be defined at once using the #define_each method.

#define_each expects at least two parameters: the collection and a proc that can be used to calculate the block name. The proc must at least one parameter, the first being the item in the collection.

The method also expects either an options hash designating the render strategy or a Ruby block.