# Hooking Blocks

```
"before_all" hooks
"around_all" hooks
  "around" hooks
    "before" hooks
      "surround" hook
        "prepend" hooks
        block
        "append" hooks
    "after" hooks
"after_all" hooks
```

Hooks may be registered for a specific block that render additional code in relation to the block when the block is rendered.

There is no limit to the number of hooks that may be registered for a block, and multiple hooks may be registered of the same hook type for a block.

<aside class="notice">
  Hooks will still render even if there is no associated block to be rendered.
</aside>

Hooks fall into three categories:

## Before Hooks

Before hooks render code before their corresponding block renders.

<aside class="warning">
  All Before hooks of a given type will render in reverse order from the order in which they are registered.
</aside>

There are three levels of "before" hooks:

### "prepend" Hooks

```erb
<% blocks.prepend :my_block do %>
  "prepend" call 1
  <br>
<% end %>

<% blocks.surround :my_block do |b| %>
  "surround" call before
  <br>
  <%= b.call %>
  "surround" call after
  <br>
<% end %>

<% blocks.prepend :my_block do %>
  "prepend" call 2
  <br>
<% end %>

<%= blocks.render :my_block do %>
  "my_block" content
  <br>
<% end %>
```

```haml
- blocks.prepend :my_block do
  "prepend" call 1
  %br

- blocks.surround :my_block do |b|
  "surround" call before
  %br
  = b.call
  "surround" call after
  %br

- blocks.prepend :my_block do
  "prepend" call 2
  %br

= blocks.render :my_block do
  "my_block" content
  %br
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.prepend :my_block do
  '"prepend" call 1' +
  builder.content_tag(:br)
end

builder.surround :my_block do |b|
  '"surround" call before' +
  builder.content_tag(:br) +
  b.call +
  '"surround" call after' +
  builder.content_tag(:br)
end

builder.prepend :my_block do
  '"prepend" call 2' +
  builder.content_tag(:br)
end

builder.render :my_block do
  '"my_block" content' +
  builder.content_tag(:br)
end
```

> The output will be:

```html
"surround" call before
"prepend" call 2
"prepend" call 1
"my_block" content
"surround" call after
```

"prepend" hooks render content that immediately precedes the block content itself.

They render in closest proximity to the block along with the their sibling "append" hooks.

Together with the block content itself and the sibling "append" hooks, they can be surrounded with "surround" calls.

<aside class="notice">
  Take note that the second "prepend" call content rendered first and that the "surround" call surrounded all the prepended content as well as the content block itself.
</aside>

### "before" Hooks

```erb
<% blocks.before :my_block do %>
  "before" call 1
  <br>
<% end %>

<% blocks.surround :my_block do |b| %>
  "surround" call before
  <br>
  <%= b.call %>
  "surround" call after
  <br>
<% end %>

<% blocks.around :my_block do |b| %>
  "Around" call before
  <br>
  <%= b.call %>
  "Around" call after
  <br>
<% end %>

<% blocks.before :my_block do %>
  "before" call 2
  <br>
<% end %>

<%= blocks.render :my_block do %>
  "my_block" content
  <br>
<% end %>
```

```haml
- blocks.before :my_block do
  "before" call 1
  %br

- blocks.surround :my_block do |b|
  "surround" call before
  %br
  = b.call
  "surround" call after
  %br

- blocks.around :my_block do |b|
  "around" call before
  %br
  = b.call
  "around" call after
  %br

- blocks.before :my_block do
  "before" call 2
  %br

= blocks.render :my_block do
  "my_block" content
  %br
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.before :my_block do
  '"before" call 1' +
  builder.content_tag(:br)
end

builder.surround :my_block do |b|
  '"surround" call before' +
  builder.content_tag(:br) +
  b.call +
  '"surround" call after' +
  builder.content_tag(:br)
end

builder.around :my_block do |b|
  '"around" call before' +
  builder.content_tag(:br) +
  b.call +
  '"around" call after' +
  builder.content_tag(:br)
end

builder.before :my_block do
  '"before" call 2' +
  builder.content_tag(:br)
end

builder.render :my_block do
  '"my_block" content' +
  builder.content_tag(:br)
end
```

> The output will be:

```html
"around" call before
"before" call 2
"before" call 1
"surround" call before
"my_block" content
"surround" call after
"around" call after
```

"before" hooks render content before "surround" hooks.

Together with the all "surround" content and the sibling "after" hooks, they can be surrounded with "around" calls.

<aside class="notice">
  Take note that the second "before" call content rendered first and that the "around" call surrounded all the before content as well as the surrounded content.
</aside>

### "before_all" Hooks

```erb
<% blocks.before_all :my_block do %>
  "before" call 1
  <br>
<% end %>

<% blocks.around_all :my_block do |b| %>
  "around_all" call before
  <br>
  <%= b.call %>
  "around_all" call after
  <br>
<% end %>

<% blocks.before_all :my_block do %>
  "before_all" call 2
  <br>
<% end %>

<%= blocks.render :my_block do %>
  "my_block" content
  <br>
<% end %>
```

```haml
- blocks.before_all :my_block do
  "before_all" call 1
  %br

- blocks.around_all :my_block do |b|
  "around_all" call before
  %br
  = b.call
  "around_all" call after
  %br

- blocks.before_all :my_block do
  "before_all" call 2
  %br

= blocks.render :my_block do
  "my_block" content
  %br
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.before :my_block do
  '"before" call 1' +
  builder.content_tag(:br)
end

builder.surround :my_block do |b|
  '"surround" call before' +
  builder.content_tag(:br) +
  b.call +
  '"surround" call after' +
  builder.content_tag(:br)
end

builder.around :my_block do |b|
  '"around" call before' +
  builder.content_tag(:br) +
  b.call +
  '"around" call after' +
  builder.content_tag(:br)
end

builder.before :my_block do
  '"before" call 2' +
  builder.content_tag(:br)
end

builder.render :my_block do
  '"my_block" content' +
  builder.content_tag(:br)
end
```

> The output will be:

```html
"before_all" call 2
"before_all" call 1
"around_all" call before
"my_block" content
"around_all" call after
```

"before_all" hooks render content before anything else, including any "around_all" hooks.

<aside class="notice">
  Take note that the second "before_all" call content rendered first before anything else including the "around_all" hook.
</aside>

## After Hooks

After hooks render code before their corresponding block renders.

<aside class="warning">
  Unlike "Before" and "Around" hooks, "After" hooks of a given type will render in the order in which they are registered.
</aside>

There are three levels of "after" hooks:

### "append" Hooks

```erb
<% blocks.append :my_block do %>
  "append" call 1
  <br>
<% end %>

<% blocks.surround :my_block do |b| %>
  "surround" call before
  <br>
  <%= b.call %>
  "surround" call after
  <br>
<% end %>

<% blocks.append :my_block do %>
  "append" call 2
  <br>
<% end %>

<%= blocks.render :my_block do %>
  "my_block" content
  <br>
<% end %>
```

```haml
- blocks.append :my_block do
  "append" call 1
  %br

- blocks.surround :my_block do |b|
  "surround" call before
  %br
  = b.call
  "surround" call after
  %br

- blocks.append :my_block do
  "append" call 2
  %br

= blocks.render :my_block do
  "my_block" content
  %br
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.append :my_block do
  '"prepend" call 1' +
  builder.content_tag(:br)
end

builder.surround :my_block do |b|
  '"surround" call before' +
  builder.content_tag(:br) +
  b.call +
  '"surround" call after' +
  builder.content_tag(:br)
end

builder.append :my_block do
  '"prepend" call 2' +
  builder.content_tag(:br)
end

builder.render :my_block do
  '"my_block" content' +
  builder.content_tag(:br)
end
```

> The output will be:

```html
"surround" call before
"my_block" content
"append" call 1
"append" call 2
"surround" call after
```

"append" hooks render content that immediately follows the block content itself.

They render in closest proximity to the block along with the their sibling "prepend" hooks.

Together with the block content itself and the sibling "prepend" hooks, they can be surrounded with "surround" calls.

<aside class="notice">
  Take note that the second "append" call content rendered after the first and that the "surround" call surrounded all the appended content as well as the content block itself.
</aside>

### "after" Hooks

```erb
<% blocks.after :my_block do %>
  "after" call 1
  <br>
<% end %>

<% blocks.surround :my_block do |b| %>
  "surround" call before
  <br>
  <%= b.call %>
  "surround" call after
  <br>
<% end %>

<% blocks.around :my_block do |b| %>
  "Around" call before
  <br>
  <%= b.call %>
  "Around" call after
  <br>
<% end %>

<% blocks.after :my_block do %>
  "after" call 2
  <br>
<% end %>

<%= blocks.render :my_block do %>
  "my_block" content
  <br>
<% end %>
```

```haml
- blocks.after :my_block do
  "after" call 1
  %br

- blocks.surround :my_block do |b|
  "surround" call before
  %br
  = b.call
  "surround" call after
  %br

- blocks.around :my_block do |b|
  "around" call before
  %br
  = b.call
  "around" call after
  %br

- blocks.after :my_block do
  "after" call 2
  %br

= blocks.render :my_block do
  "my_block" content
  %br
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.after :my_block do
  '"after" call 1' +
  builder.content_tag(:br)
end

builder.surround :my_block do |b|
  '"surround" call before' +
  builder.content_tag(:br) +
  b.call +
  '"surround" call after' +
  builder.content_tag(:br)
end

builder.around :my_block do |b|
  '"around" call before' +
  builder.content_tag(:br) +
  b.call +
  '"around" call after' +
  builder.content_tag(:br)
end

builder.after :my_block do
  '"after" call 2' +
  builder.content_tag(:br)
end

builder.render :my_block do
  '"my_block" content' +
  builder.content_tag(:br)
end
```

> The output will be:

```html
"around" call before
"surround" call before
"my_block" content
"surround" call after
"after" call 1
"after" call 2
"around" call after
```

"after" hooks render content after "surround" hooks.

Together with the all "surround" content and the sibling "before" hooks, they can be surrounded with "around" calls.

<aside class="notice">
  Take note that the second "after" call content rendered after the first and that the "around" call surrounded all the after content as well as the surrounded content.
</aside>

### "after_all" Hooks

```erb
<% blocks.after_all :my_block do %>
  "after_all" call 1
  <br>
<% end %>

<% blocks.around_all :my_block do |b| %>
  "around_all" call before
  <br>
  <%= b.call %>
  "around_all" call after
  <br>
<% end %>

<% blocks.after_all :my_block do %>
  "after_all" call 2
  <br>
<% end %>

<%= blocks.render :my_block do %>
  "my_block" content
  <br>
<% end %>
```

```haml
- blocks.after_all :my_block do
  "after_all" call 1
  %br

- blocks.around_all :my_block do |b|
  "around_all" call before
  %br
  = b.call
  "around_all" call after
  %br

- blocks.after_all :my_block do
  "after_all" call 2
  %br

= blocks.render :my_block do
  "my_block" content
  %br
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.after_all :my_block do
  '"after_all" call 1' +
  builder.content_tag(:br)
end

builder.surround :my_block do |b|
  '"surround" call before' +
  builder.content_tag(:br) +
  b.call +
  '"surround" call after' +
  builder.content_tag(:br)
end

builder.around :my_block do |b|
  '"around" call before' +
  builder.content_tag(:br) +
  b.call +
  '"around" call after' +
  builder.content_tag(:br)
end

builder.after_all :my_block do
  '"after_all" call 2' +
  builder.content_tag(:br)
end

builder.render :my_block do
  '"my_block" content' +
  builder.content_tag(:br)
end
```

> The output will be:

```html
"around_all" call before
"my_block" content
"around_all" call after
"after_all" call 1
"after_all" call 2
```

"after_all" hooks render content after anything else, including any "around_all" hooks.

<aside class="notice">
  Take note that the second "after_all" call content rendered after everything else.
</aside>

## Around Hooks

Around hooks render code around their corresponding block, allowing the hook to render code before the block renders, pass control over to the rendering block, and then regain control once the block has rendered.

<aside class="warning">
  Around hooks are expected to be provided a block which takes a block as its first argument. They should "call" that block when they are ready to pass control to the content they are surrounding.
</aside>

<aside class="warning">
  All around hooks of a given type will render in reverse order from the order in which they are registered.
</aside>

There are three levels of around hooks:

### "surround" Hooks

```erb
<% blocks.prepend :my_block do %>
  "prepend" call
  <br>
<% end %>

<% blocks.before :my_block do %>
  "before" call
  <br>
<% end %>

<% blocks.append :my_block do %>
  "append" call
  <br>
<% end %>

<% blocks.after :my_block do %>
  "after" call
  <br>
<% end %>

<% blocks.surround :my_block do |b| %>
  "surround" call 1 before
  <br>
  <%= b.call %>
  "surround" call 1 after
  <br>
<% end %>

<% blocks.surround :my_block do |b| %>
  "surround" call 2 before
  <br>
  <%= b.call %>
  "surround" call 2 after
  <br>
<% end %>

<%= blocks.render :my_block do %>
  "my_block" content
  <br>
<% end %>
```

```haml
- blocks.prepend :my_block do
  "prepend" call
  %br

- blocks.before :my_block do
  "before" call
  %br

- blocks.append :my_block do
  "append" call
  %br

- blocks.after :my_block do
  "after" call
  %br

- blocks.surround :my_block do |b|
  "surround" call 1 before
  %br
  = b.call
  "surround" call 1 after
  %br

- blocks.surround :my_block do |b|
  "surround" call 2 before
  %br
  = b.call
  "surround" call 2 after
  %br

= blocks.render :my_block do
  "my_block" content
  %br
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.prepend :my_block do
  '"prepend" call' +
  builder.content_tag(:br)
end

builder.before :my_block do
  '"before" call' +
  builder.content_tag(:br)
end

builder.append :my_block do
  '"append" call' +
  builder.content_tag(:br)
end

builder.after :my_block do
  '"after" call' +
  builder.content_tag(:br)
end

builder.surround :my_block do |b|
  '"surround" call 1 before' +
  builder.content_tag(:br) +
  b.call +
  '"surround" call 1 after' +
  builder.content_tag(:br)
end

builder.surround :my_block do |b|
  '"surround" call 2 before' +
  builder.content_tag(:br) +
  b.call +
  '"surround" call 2 after' +
  builder.content_tag(:br)
end

builder.render :my_block do
  '"my_block" content' +
  builder.content_tag(:br)
end
```

> The output will be:

```html
"before" call
"surround" call 2 before
"surround" call 1 before
"prepend" call
"my_block" content
"append" call
"surround" call 1 after
"surround" call 2 after
"after" call
```

"surround" hooks render content that surround the combination of "prepend" hooks, the block content, and "append" hooks. The can be preceded by "before" hooks and followed by "after" hooks.

<aside class="notice">
  Take note that the second "surround" call content rendered around the first.
</aside>

### "around" Hooks

```erb
<% blocks.before :my_block do %>
  "before" call
  <br>
<% end %>

<% blocks.after :my_block do %>
  "after" call
  <br>
<% end %>

<% blocks.around :my_block do |b| %>
  "around" call 1 before
  <br>
  <%= b.call %>
  "around" call 1 after
  <br>
<% end %>

<% blocks.around_all :my_block do |b| %>
  "around_all" call before
  <br>
  <%= b.call %>
  "around_all" call after
  <br>
<% end %>

<% blocks.around :my_block do |b| %>
  "around" call 2 before
  <br>
  <%= b.call %>
  "around" call 2 after
  <br>
<% end %>

<%= blocks.render :my_block do %>
  "my_block" content
  <br>
<% end %>
```

```haml
- blocks.before :my_block do
  "before" call
  %br

- blocks.after :my_block do
  "after" call
  %br

- blocks.around :my_block do |b|
  "around" call 1 before
  %br
  = b.call
  "around" call 1 after
  %br

- blocks.around_all :my_block do |b|
  "around_all" call before
  %br
  = b.call
  "around_all" call after
  %br

- blocks.around :my_block do |b|
  "around" call 2 before
  %br
  = b.call
  "around" call 2 after
  %br

= blocks.render :my_block do
  "my_block" content
  %br
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.before :my_block do
  '"before" call' +
  builder.content_tag(:br)
end

builder.after :my_block do
  '"after" call' +
  builder.content_tag(:br)
end

builder.around :my_block do |b|
  '"around" call 1 before' +
  builder.content_tag(:br) +
  b.call +
  '"around" call 1 after' +
  builder.content_tag(:br)
end

builder.around_all :my_block do |b|
  '"around_all" call before' +
  builder.content_tag(:br) +
  b.call +
  '"around_all" call after' +
  builder.content_tag(:br)
end

builder.around :my_block do |b|
  '"around" call 2 before' +
  builder.content_tag(:br) +
  b.call +
  '"around" call 2 after' +
  builder.content_tag(:br)
end

builder.render :my_block do
  '"my_block" content' +
  builder.content_tag(:br)
end
```

> The output will be:

```html
"around_all" call before
"around" call 2 before
"around" call 1 before
"before" call
"my_block" content
"after" call
"around" call 1 after
"around" call 2 after
"around_all" call after
```

"around" hooks render content that surrounds the combination of "before" hooks, "surround" content, and "after" hooks. They can be surrounded by "around_all" hooks.

<aside class="notice">
  Take note that the second "around" call content rendered around the first.
</aside>

### "around_all" Hooks

```erb
<% blocks.before :my_block do %>
  "before" call
  <br>
<% end %>

<% blocks.after :my_block do %>
  "after" call
  <br>
<% end %>

<% blocks.around :my_block do |b| %>
  "around" call 1 before
  <br>
  <%= b.call %>
  "around" call 1 after
  <br>
<% end %>

<% blocks.around_all :my_block do |b| %>
  "around_all" call before
  <br>
  <%= b.call %>
  "around_all" call after
  <br>
<% end %>

<% blocks.around :my_block do |b| %>
  "around" call 2 before
  <br>
  <%= b.call %>
  "around" call 2 after
  <br>
<% end %>

<%= blocks.render :my_block do %>
  "my_block" content
  <br>
<% end %>
```

```haml
- blocks.before_all :my_block do
  "before_all" call
  %br

- blocks.after_all :my_block do
  "after_all" call
  %br

- blocks.around_all :my_block do |b|
  "around_all" call 1 before
  %br
  = b.call
  "around_all" call 1 after
  %br

- blocks.around :my_block do |b|
  "around" call before
  %br
  = b.call
  "around" call after
  %br

- blocks.around_all :my_block do |b|
  "around_all" call 2 before
  %br
  = b.call
  "around_all" call 2 after
  %br

= blocks.render :my_block do
  "my_block" content
  %br
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.before_all :my_block do
  '"before_all" call' +
  builder.content_tag(:br)
end

builder.after_all :my_block do
  '"after_all" call' +
  builder.content_tag(:br)
end

builder.around_all :my_block do |b|
  '"around_all" call 1 before' +
  builder.content_tag(:br) +
  b.call +
  '"around_all" call 1 after' +
  builder.content_tag(:br)
end

builder.around :my_block do |b|
  '"around" call before' +
  builder.content_tag(:br) +
  b.call +
  '"around" call after' +
  builder.content_tag(:br)
end

builder.around_all :my_block do |b|
  '"around_all" call 2 before' +
  builder.content_tag(:br) +
  b.call +
  '"around_all" call 2 after' +
  builder.content_tag(:br)
end

builder.render :my_block do
  '"my_block" content' +
  builder.content_tag(:br)
end
```

> The output will be:

```html
"before_all" call
"around_all" call 2 before
"around_all" call 1 before
"around" call before
"my_block" content
"around" call after
"around_all" call 1 after
"around_all" call 2 after
"after_all" call
```

"around_all" hooks render content that surrounds "around" hooks. They can be preceded by "before_all" hooks and followed by "after_all" hooks.

<aside class="notice">
  Take note that the second "around_all" call content rendered around the first.
</aside>

## With Options

```erb
<% blocks.define :my_block,
  a: "Block def",
  b: "Block def" %>

<% blocks.around :my_block,
  a: "Hook def",
  c: "Hook def" do |block, options| %>
  Options are <%= options.inspect %>
  <%= block.call %>
<% end %>

<%= blocks.render :my_block %>
```

```haml
- blocks.define :my_block,
  a: "Block def",
  b: "Block def"

- blocks.around :my_block,
  a: "Hook def",
  c: "Hook def" do |block, options|
  Options are
  = options.inspect
  = block.call

= blocks.render :my_block
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.define :my_block,
  a: "Block def",
  b: "Block def"

builder.around :my_block,
  a: "Hook def",
  c: "Hook def" do |block, options|

  "Options are #{options.inspect} #{block.call}"
end
builder.render :my_block
```

> When rendered, this will produce the following output:

```
Options are {
  "a"=>"Hook def",
  "c"=>"Hook def",
  "b"=>"Block def"
}
```

Just as Blocks may be defined with options, so too may hooks be defined with options. When the hook is rendered, these options will take a higher merge precedence than the options that were defined on the block itself. They will however take a lower merge precedence than any render items that were specified when the render call was made for the block being hooked (however, any of the reserved-keywords that are sent to the render call will have already been stripped out).

## With a Partial

```erb
<% blocks.before :my_block,
  partial: "some_partial" %>
```

```haml
- blocks.before :my_block,
  partial: "some_partial"
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.before :my_block,
  partial: "some_partial"
```

Hooks may also be defined with Rails partials using the "partial" keyword.

## With a Proxy to Another Block

```erb
<% blocks.before :my_block,
  with: :some_proxy_block %>
```

```haml
- blocks.before :my_block,
  with: :some_proxy_block
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.after :my_block,
  with: :some_proxy_block
```

Hooks may also be defined with a proxy to another block using the "with" keyword.
