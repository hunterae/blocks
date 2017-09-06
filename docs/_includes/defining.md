# Defining Blocks

```erb
<% blocks.define :my_block %>
<!-- OR -->
<% blocks.define "my_block" %>
```

```haml
- blocks.define :my_block
#- OR
- blocks.define "my_block"
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.define :my_block
# OR
builder.define "my_block"
```

With Blocks, you can define a block of code for later rendering using Ruby blocks, Rails partials, and proxies to other blocks.

A block consists of a name, a hash of options, and a rendering strategy (also called its definition).

A block's name can be a symbol or a string. The underlying system treats symbols and strings the same. Therefore, any block that is defined with a String name can be accessed with its corresponding symbol name and vice-versa.

## With a Ruby Block

```erb
<% blocks.define :my_block do %>
  content
<% end %>
```

```haml
- blocks.define :my_block do
  content
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.define :my_block do
  "content"
end
```

A Block may be defined as a standard Ruby block.

### With a Proc

```erb
<% my_block =
  Proc.new { "content" } %>
<% blocks.define :my_block,
          block: my_block %>
<!-- OR -->
<% blocks.define :my_block,
                 &my_block %>
```

```haml
- my_block = Proc.new { "content" }
- blocks.define :my_block,
         block: my_block
-# OR
- blocks.define :my_block, &my_block
```

```ruby
# where builder is an instance
#  of Blocks::Builder
my_block = Proc.new { "content" }
builder.define :my_block,
  block: my_block
#OR...
builder.define :my_block, &my_block
```

It may also be defined with a Proc

### With a Lambda

```erb
<% my_block = lambda { "content" } %>
<% blocks.define :my_block,
          block: my_block %>
<!-- OR -->
<% blocks.define :my_block, &my_block %>
```

```haml
Lambdas are kind of a pain in Haml
and Procs should be used instead
```

```ruby
# where builder is an instance
#  of Blocks::Builder
my_block = lambda { "content" }
builder.define :my_block,
  block: my_block
# OR...
builder.define :my_block, &my_block
```

It may also be defined with a Lambda

## With a Rails Partial

```erb
<%= blocks.define :my_block,
         partial: "my_partial" %>
```

```haml
- blocks.define :my_block,
       partial: "my_partial"
```

```ruby
# where builder is an instance
#  of Blocks::Builder
- builder.define :my_block,
        partial: "my_partial"
```

A Block may be defined as a Rails partial using the "partial" keyword in the parameters. Whenever the Block gets rendered, the partial actually gets rendered.

## With a Proxy to Another Block

```erb
<% blocks.define :my_block,
           with: :some_proxy_block %>
```

```haml
- blocks.define :my_block,
          with: :some_proxy_block
```

```ruby
# where builder is an instance
#  of Blocks::Builder
- builder.define :my_block,
           with: :some_proxy_block
```

A Block may be defined as a proxy to another block using the "with" keyword in the parameters.

### Proxying to a method

```erb
<% builder.define :my_block,
            with: :column %>
```

```haml
- builder.define :my_block,
           with: :column
```

```ruby
builder.define :my_block,
         with: :column
```

> Where "builder" is an instance of a class that extends Blocks::Builder and has a method called "column".

The "with" keyword may also specify the name of a method that will be called on the builder instance when the block is rendered. By default, this will be an instance of Blocks::Builder.

Also, a Proxy block can point to a method on the builder instance (by default, this is an instance of Blocks::Builder).

### Proxying to a Proxy

```erb
<% blocks.define :my_block,
           with: :proxy_1 %>
<% blocks.define :proxy_1,
           with: :proxy_2 %>
<% blocks.define :proxy_2 do %>
  My proxied proxied content
<% end %>
```

```haml
- blocks.define :my_block,
          with: :proxy_1
- blocks.define :proxy_1,
          with: :proxy_2
- blocks.define :proxy_2 do
  My proxied proxied content
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.define :my_block,
         with: :proxy_1
builder.define :proxy_1,
         with: :proxy_2
builder.define :proxy_2 do
  "My proxied proxied content"
end
```

Proxy Blocks can also be chained together though separate definitions. The order of Block definitions is irrelevant - with two caveats:

1. Proxies must be setup before attempting to render them
2. If the same block name is defined multiple times with different proxy names, the first one defined will be used

## With Multiple Definitions

```erb
<% blocks.define :my_block,
        partial: "my_partial" %>
<% blocks.define :my_block,
        with: :my_proxy %>
<% blocks.define :my_block do %>
  My Block Definition
<% end %>
```

```haml
- blocks.define :my_block,
       partial: "my_partial"
- blocks.define :my_block,
          with: :my_proxy
- blocks.define :my_block do
  My Block Definition
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.define :my_block,
      partial: "my_partial"
builder.define :my_block,
         with: :my_proxy
builder.define :my_block do
  "My Block Definition"
end
```

> :my_block will use the partial: "my_partial" when rendered

When multiple definitions for the same block name are provided, Blocks will utilize the first definition to occur, whether it's a Ruby block, a Rails partial, or a Proxy to another block.

## Without a Definition

```erb
<% blocks.define :my_block %>
```

```haml
- blocks.define :my_block
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.define :my_block
```

Blocks do not need to have a definition provided. When they are rendered, no output is generated.

This, in itself, is not particularly useful, but can become more and more useful when block options and hooks and wrappers are combined.

## With a Collection

```erb
<% blocks.define :my_block,
  collection: [1, 2, 3, 4] do |item| %>
  <li>Item: <%= item %></li>
<% end %>
```

```haml
- blocks.define :my_block,
  collection: [1, 2, 3, 4] do |item|
  %li= "Item: #{item}"
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.define :my_block,
  collection: [1, 2, 3, 4] do |item|
  builder.content_tag :li,
    "Item #{item}"
end
```

A collection may be defined for a block, in which case, when that block is rendered, it will actually render the block multiple times, once for each item in the collection.

<aside class="warning">
When the block definition is a Ruby block, the block should be prepared to take each item from the collection as a parameter.
</aside>


### With an Alias

```erb
<% blocks.define :my_block,
     collection: [1, 2, 3, 4],
             as: :item,
        partial: "my_partial" %>
```

```haml
- blocks.define :my_block,
    collection: [1, 2, 3, 4],
            as: :item,
       partial: "my_partial"
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.define :my_block,
   collection: [1, 2, 3, 4],
           as: :item,
      partial: "my_partial"
```

Additionally, you can set an alias for each item in the collection as the collection is iterated over. This is done using the "as" option.

If the block being rendered is a partial, it will alias each item in the collection with the specified option (i.e. the value of the "as" option will become the name of the variable available in the partial being rendered and will contain each item in the collection being rendered). Additionally, "current_index" will also be a variable that can be accessed within the partial, and will correspond to the item's index in the collection.

If the block being rendered is not a partial, it will store the alias name as a key in an options hash that will be optionally passed to the block when it is rendered. Additionally, "current_index" will store the item's current index within the collection.

### Without an Alias

When no alias is specified and the block being rendered is a partial, it will alias each item in the collection as "object" (i.e. "object" will become the name of the variable available in the partial being rendered and will contain each item in the collection being rendered).
Additionally, "current_index" will also be a variable that can be accessed within the partial, and will correspond to the item's index in the collection.

If the block being rendered is not a partial, it will store "object" as a key in an options hash that will be optionally passed to the block when it is rendered. Additionally, "current_index" will store the item's current index within the collection.

## With Options

```erb
<% blocks.define :my_block,
  a: "First setting of a" %>
<% blocks.define :my_block,
  a: "Second setting of a",
  b: "First setting of b" %>
<% blocks.define :my_block,
  a: "Third setting of a",
  b: "Second setting setting of b",
  c: "First setting of c" %>
```

```haml
- blocks.define :my_block,
  a: "First setting of a"
- blocks.define :my_block,
  a: "Second setting of a",
  b: "First setting of b"
- blocks.define :my_block,
  a: "Third setting of a",
  b: "Second setting setting of b",
  c: "First setting of c"
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.define :my_block,
  a: "First setting of a"
builder.define :my_block,
  a: "Second setting of a",
  b: "First setting of b"
builder.define :my_block,
  a: "Third setting of a",
  b: "Second setting setting of b",
  c: "First setting of c"
```

> After running the above code, the options for :my_block will look like this:

```JavaScript
{
  a: "First setting of a",
  b: "First setting of b",
  c: "First setting of c"
}
```

Blocks are maintaining a merged, mutable options hash. This set is mutated with repeated calls to "define".

When the same option key is used in successive "define" calls, the first call to define a key's value is given priority.

### Indifferent Access

```erb
<% blocks.define :my_block,
  a: "First setting of a",
  "b" => "First setting of b" %>
<% blocks.define :my_block,
  "a" => "Second setting of a",
  b: "Second setting of b" %>
```

```haml
- blocks.define :my_block,
  a: "First setting of a",
  "b" => "First setting of b"
- blocks.define :my_block,
  "a" => "Second setting of a",
  b: "Second setting of b"
```

```ruby
# where builder is an instance of
#  Blocks::Builder
builder.define :my_block,
  a: "First setting of a",
  "b" => "First setting of b"
builder.define :my_block,
  "a" => "Second setting of a",
  b: "First setting of b"
```

> After running the above code, the options for :my_block will look like this:

```JavaScript
{
  a: "First setting of a",
  b: "First setting of b"
}
```

Like the name of the block itself, the options hash does not care whether a symbol or a string is provided as a hash key; they are treated the same.

### Deep Merging of Options

```erb
<% blocks.define :my_block,
              a: 1,
     shared_key: {
       a: "a1"
     } %>
<% blocks.define :my_block,
              b: 1,
     shared_key: {
       a: "a2",
       b: "b1"
     } %>
```

```haml
- blocks.define :my_block,
             a: 1,
    shared_key: { a: "a1" }
- blocks.define :my_block,
             b: 1,
    shared_key: { a: "a2",
                  b: "b1" }
```

```ruby
# where builder is an instance of
#  Blocks::Builder
builder.define :my_block,
            a: 1,
   shared_key: {
     a: "a1"
   }
builder.define :my_block,
            b: 1,
   shared_key: {
     a: "a2",
     b: "b1"
   }
```

> After running the above code, the options for :my_block will look like this:

```JavaScript
{
  a: 1,
  shared_key: {
    a: "a1",
    b: "b1"
  },
  b: 1
}
```

When the same option key is used in successive "define" calls and the values for the duplicate key are both hashes, they are deep merged, giving precedence for duplicate nested keys to whatever key was defined first.

### Runtime and Default Options

```erb
<% blocks.define :my_block,
  a: "standard",
  b: "standard",
  runtime: {
    a: "runtime",
    c: "runtime"
  },
  defaults: {
    a: "default",
    d: "default"
  } %>
```

```haml
- blocks.define :my_block,
  a: "standard",
  b: "standard",
  runtime: { a: "runtime",
             c: "runtime" },
  defaults: { a: "default",
              d: "default" }
```

```ruby
# where builder is an instance of
#  Blocks::Builder
builder.define :my_block,
  a: "standard",
  b: "standard",
  runtime: {
    a: "runtime",
    c: "runtime"
  },
  defaults: {
    a: "default",
    d: "default"
  }
```

> After running the above code, the options for :my_block will look like this:

```JavaScript
{
  a: "runtime",
  c: "runtime",
  b: "standard",
  d: "default"
}
```

There are three levels of options: runtime, standard, and default. They are given merge precedence in that order.

Runtime options are specified as a nested hash with "runtime" as the key.

Default options are specified as a nested hash with "defaults" as the key.

All other keys in the hash are considered standard options.

## With Parameters

```erb
<% blocks.define :my_block,
  a: 1 do |options| %>
  My options are <%= options.inspect %>
<% end %>
```

```haml
- blocks.define :my_block,
  a: 1 do |options|
  My options are
  = options.inspect
```

```ruby
# where builder is an instance of
#  Blocks::Builder
builder.define :my_block,
  a: 1 do |options|
  "My options are #{options.inspect}"
end
```
> If this block were rendered, the output would be:

```
My options are { a: 1 }
```

Every block that are defined with a Ruby block or a proxy to a Block that is defined with a Ruby block (or a proxy to a proxy to ... to a block that is defined with a Ruby block) can optionally receive the merged options as a parameter.

## Without a Name

```erb
See Ruby tab
```

```haml
See Ruby tab
```

```ruby
# where builder is an instance of
#  Blocks::Builder
anonymous_block = builder.define do
  "hello"
end

puts anonymous_block.name
# Outputs "anonymous_block_1"

puts anonymous_block.anonymous
# Outputs true
```

Blocks may be defined without a name. When no block name is provided, an anonymous name will be generated.

<aside class="notice">
  This is really only useful directly within the Ruby code or when extending the Blocks::Builder class.
</aside>