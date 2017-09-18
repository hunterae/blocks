# Wrapping Blocks

Wrappers work similarly to hooks with a few notable exceptions:

1. Wrappers are singular in nature. While there are three different wrappers that may be applied to a block, only one of each may be applied.
2. They are defined directly on the block themselves or provided to the render call.

Wrappers may be defined with either the name of another block, method, or a Proc. That block, method, or Proc must be prepared to take at least one argument, which is the content_block to call when the wrapper is ready to yield control to the content it is wrapping.

<aside class="notice">
  Like hooks, wrappers will still render even if there is no associated block to be rendered.
</aside>

## "wrap_all" Wrapper

```erb
<% blocks.define :wrap_all do |c, o| %>
  Wrap All Start
  <%= c.call %>
  <br>Wrap All End
<% end %>

<% blocks.define :wrap_each do |c, i, o| %>
  <% if o.nil?; o = i; i = nil end %>
  <br>Wrap Each Start <%= i %><br>
  <%= c.call %>
  <br>Wrap Each End <%= i %>
<% end %>

<% blocks.around_all :my_block do |c, o| %>
  Around All Start<br>
  <%= c.call %>
  <br>Around All End<br>
<% end %>

<% blocks.define :my_block,
  wrap_all: :wrap_all,
  wrap_each: :wrap_each do %>
  content
<% end %>

With Collection:
<br>
<%= blocks.render :my_block,
  collection: ["a", "b"] %>
<br>
No Collection:
<br>
<%= blocks.render :my_block %>

<!-- OR -->
With Collection:
<br>
<%= blocks.render :my_block,
  wrap_all: :wrap_all,
  wrap_each: :wrap_each,
  collection: ["a", "b"] %>
<br>
No Collection:
<br>
<%= blocks.render :my_block,
  wrap_all: :wrap_all,
  wrap_each: :wrap_each %>
```

```haml
- blocks.define :wrap_all do |c, o|
  Wrap All Start
  = c.call
  %br
  Wrap All End

- blocks.define :wrap_each do |c, i, o|
  - if o.nil?; o = i; i = nil end
  %br
  Wrap Each Start
  = i
  %br
  = c.call
  %br
  Wrap Each End
  = i

- blocks.around_all :my_block do |c, o|
  Around All Start
  %br
  = c.call
  %br
  Around All End
  %br

- blocks.define :my_block,
  wrap_all: :wrap_all,
  wrap_each: :wrap_each do
  content

With Collection:
%br
= blocks.render :my_block,
  collection: ["a", "b"]
%br
No Collection:
%br
= blocks.render :my_block

#- OR
With Collection:
%br
= blocks.render :my_block,
  wrap_all: :wrap_all,
  wrap_each: :wrap_each,
  collection: ["a", "b"]
%br
No Collection:
%br
= blocks.render :my_block,
  wrap_all: :wrap_all,
  wrap_each: :wrap_each
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.define :wrap_all do |c, o|
  "Wrap All Start" +
  c.call +
  "<br>Wrap All End".html_safe
end

builder.define :wrap_each do |c, i, o|
  if o.nil?
    o = i
    i = nil
  end
  "<br>Wrap Each Start #{i}<br>".html_safe +
  c.call +
  "<br>Wrap Each End #{i}".html_safe
end

builder.around_all :my_block do |c, o|
  "Around All Start<br>".html_safe +
  c.call +
  "<br>Around All End<br>".html_safe
end

builder.define :my_block,
  wrap_all: :wrap_all,
  wrap_each: :wrap_each do
  "content"
end

"With Collection:<br>".html_safe +
builder.render(:my_block,
  collection: ["a", "b"]) +
"<br>No Collection:<br>".html_safe +
builder.render(:my_block)

# OR
"With Collection:<br>".html_safe +
builder.render(:my_block,
  wrap_all: :wrap_all,
  wrap_each: :wrap_each,
  collection: ["a", "b"]) +
"<br>No Collection:<br>".html_safe +
builder.render(:my_block,
  wrap_all: :wrap_all,
  wrap_each: :wrap_each)
```

> The above code will output the following:

```
With Collection:
Around All Start
Wrap All Start
Wrap Each Start a
content
Wrap Each End a
Wrap Each Start b
content
Wrap Each End b
Wrap All End
Around All End

No Collection:
Around All Start
Wrap All Start
Wrap Each Start
content
Wrap Each End
Wrap All End
Around All End
```

"wrap_all" is a wrapper that surrounds content just inside any "around_all" hooks and around a potential "wrap_each" wrapper (or multiple "wrap_each" wrappers if rendering a collection).

## "wrap_each" Wrapper

```erb
<% blocks.define :wrap_all do |c, o| %>
  Wrap All Start
  <%= c.call %>
  <br>Wrap All End<br>
<% end %>

<% blocks.define :wrap_each do |c, i, o| %>
  <% if o.nil?; o = i; i = nil end %>
  <br>Wrap Each Start <%= i %><br>
  <%= c.call %>
  <br>Wrap Each End <%= i %>
<% end %>

<% blocks.around :my_block do |c, o| %>
  Around Start<br>
  <%= c.call %>
  <br>Around End
<% end %>

<% blocks.define :my_block,
  wrap_all: :wrap_all,
  wrap_each: :wrap_each do %>
  content
<% end %>

With Collection:
<br>
<%= blocks.render :my_block,
  collection: ["a", "b"] %>
<br>
No Collection:
<br>
<%= blocks.render :my_block %>

<!-- OR -->
With Collection:
<br>
<%= blocks.render :my_block,
  wrap_all: :wrap_all,
  wrap_each: :wrap_each,
  collection: ["a", "b"] %>
<br>
No Collection:
<br>
<%= blocks.render :my_block,
  wrap_all: :wrap_all,
  wrap_each: :wrap_each %>
```

```haml
- blocks.define :wrap_all do |c, o|
  Wrap All Start
  = c.call
  %br
  Wrap All End
  %br

- blocks.define :wrap_each do |c, i, o|
  - if o.nil?; o = i; i = nil end
  %br
  Wrap Each Start
  = i
  %br
  = c.call
  %br
  Wrap Each End
  = i

- blocks.around :my_block do |c, o|
  Around Start
  %br
  = c.call
  %br
  Around End

- blocks.define :my_block,
  wrap_all: :wrap_all,
  wrap_each: :wrap_each do
  content

With Collection:
%br
= blocks.render :my_block,
  collection: ["a", "b"]
%br
No Collection:
%br
= blocks.render :my_block

#- OR
With Collection:
%br
= blocks.render :my_block,
  wrap_all: :wrap_all,
  wrap_each: :wrap_each,
  collection: ["a", "b"]
%br
No Collection:
%br
= blocks.render :my_block,
  wrap_all: :wrap_all,
  wrap_each: :wrap_each
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.define :wrap_all do |c, o|
  "Wrap All Start" +
  c.call +
  "<br>Wrap All End".html_safe
end

builder.define :wrap_each do |c, i, o|
  if o.nil?
    o = i
    i = nil
  end
  "<br>Wrap Each Start #{i}<br>".html_safe +
  c.call +
  "<br>Wrap Each End #{i}<br>".html_safe
end

builder.around :my_block do |c, o|
  "Around Start<br>".html_safe +
  c.call +
  "<br>Around End".html_safe
end

builder.define :my_block,
  wrap_all: :wrap_all,
  wrap_each: :wrap_each do
  "content"
end

"With Collection:<br>".html_safe +
builder.render(:my_block,
  collection: ["a", "b"]) +
"<br>No Collection:<br>".html_safe +
builder.render(:my_block)

# OR
"With Collection:<br>".html_safe +
builder.render(:my_block,
  wrap_all: :wrap_all,
  wrap_each: :wrap_each,
  collection: ["a", "b"]) +
"<br>No Collection:<br>".html_safe +
builder.render(:my_block,
  wrap_all: :wrap_all,
  wrap_each: :wrap_each)
```

> The above code will output the following:

```
With Collection:
With Collection:
Wrap All Start
Wrap Each Start a
Around Start
content
Around End
Wrap Each End a
Wrap Each Start b
Around Start
content
Around End
Wrap Each End b
Wrap All End

No Collection:
Wrap All Start
Wrap Each Start
Around Start
content
Around End
Wrap Each End
Wrap All End
```

*Also aliased to "outer_wrapper"*

When a collection is involved, the "wrap_each" wrapper will wrap each item in the collection with this wrapper, and all of these wrappers can be wrapped together using the "wrap_all" wrapper.

When no collection is involved, the "wrap_each" wrapper will simply act as another wrapper that can be wrapped within the "wrap_all" wrapper and just outside any "wrap_each" wrappers.

## "wrap_with" Wrapper

```erb
<% blocks.surround :my_block do |c, i| %>
  <% i = nil if i.is_a?(Blocks::RuntimeContext) %>
  Surround Start <%= i %><br>
  <%= c.call %>
  <br>Surround End <%= i %>
<% end %>

<% blocks.define :wrap_with do |c, i| %>
  <% i = nil if i.is_a?(Blocks::RuntimeContext) %>
  Wrap With Start <%= i %><br>
  <%= c.call %>
  <br>Wrap Wrap End <%= i %>
<% end %>

<% blocks.before :my_block do |i| %>
  <% i = nil if i.is_a?(Blocks::RuntimeContext) %>
  Before <%= i %><br>
<% end %>

<% blocks.after :my_block do |i| %>
  <% i = nil if i.is_a?(Blocks::RuntimeContext) %>
  <br>After <%= i %><br>
<% end %>

<% blocks.define :my_block,
  wrap_with: :wrap_with do %>
  content
<% end %>

With Collection:
<br>
<%= blocks.render :my_block,
  collection: ["a", "b"] %>
<br>
No Collection:
<br>
<%= blocks.render :my_block %>

<!-- OR -->
With Collection:
<br>
<%= blocks.render :my_block,
  wrap_with: :wrap_with,
  collection: ["a", "b"] %>
<br>
No Collection:
<br>
<%= blocks.render :my_block,
  wrap_with: :wrap_with %>
```

```haml
- blocks.surround :my_block do |c, i|
  - i = nil if i.is_a?(Blocks::RuntimeContext)
  Surround Start
  = i
  %br
  = c.call
  %br
  Surround End
  = i


- blocks.define :wrap_with do |c, i|
  - i = nil if i.is_a?(Blocks::RuntimeContext)
  Wrap With Start
  = i
  %br
  = c.call
  %br
  Wrap Wrap End
  = i

- blocks.before :my_block do |i|
  - i = nil if i.is_a?(Blocks::RuntimeContext)
  Before
  = i
  %br

- blocks.after :my_block do |i|
  - i = nil if i.is_a?(Blocks::RuntimeContext)
  %br
  After
  = i
  %br

- blocks.define :my_block,
  wrap_with: :wrap_with do
  content

With Collection:
%br
= blocks.render :my_block,
  collection: ["a", "b"]
%br
No Collection:
%br
= blocks.render :my_block

-# OR
With Collection:
%br
= blocks.render :my_block,
  wrap_with: :wrap_with,
  collection: ["a", "b"]
%br
No Collection:
%br
= blocks.render :my_block,
  wrap_with: :wrap_with
```

```ruby
# where builder is an instance
#  of Blocks::Builder
builder.surround :my_block do |c, i|
  i = nil if i.is_a?(Blocks::RuntimeContext)
  "Surround Start #{i}<br>".html_safe +
  c.call +
  "<br>Surround End #{i}".html_safe
end

builder.define :wrap_with do |c, i|
  i = nil if i.is_a?(Blocks::RuntimeContext)
  "Wrap With Start #{i}<br>".html_safe +
  c.call +
  "<br>Wrap Wrap End #{i}".html_safe
end

builder.before :my_block do |i|
  i = nil if i.is_a?(Blocks::RuntimeContext)
  "Before #{i}<br>".html_safe
end

builder.after :my_block do |i|
  i = nil if i.is_a?(Blocks::RuntimeContext)
  "<br>After #{i}<br>".html_safe
end

builder.define :my_block,
  wrap_with: :wrap_with do
  "content"
end

"With Collection:<br>".html_safe
builder.render(:my_block,
  wrap_with: :wrap_with,
  collection: ["a", "b"]) +
"<br>No Collection:<br>".html_safe +
builder.render(:my_block,
  wrap_with: :wrap_with)

# OR
"With Collection:<br>".html_safe
builder.render(:my_block,
  wrap_with: :wrap_with,
  collection: ["a", "b"]) +
"<br>No Collection:<br>".html_safe +
builder.render(:my_block,
  wrap_with: :wrap_with)
```

> The above code will output the following:

```
With Collection:
Before a
Wrap With Start a
Surround Start a
content
Surround End a
Wrap Wrap End a
After a
Before b
Wrap With Start b
Surround Start b
content
Surround End b
Wrap Wrap End b
After b

No Collection:
Before
Wrap With Start
Surround Start
content
Surround End
Wrap Wrap End
After
```

*Also aliased to "wrap", "wrapper", and "inner_wrapper"*

The "wrap_with" wrapper is preceded by "before" hooks, followed by "after" hooks, surrounded by "around" hooks, and wraps around "surround" hooks.

## Defining a wrapper with a Proc

Wrappers can also be defined with Procs. The Proc must take, at a minimum, the content_block that they are wrapping, as the first argument. They may optionally take the options hash as their second argument.

```erb
<% wrapper = Proc.new do |b| %>
  <div>
    <%= b.call %>
  </div>
<% end %>
<% blocks.define :my_block,
  wrapper: wrapper %>
<%= blocks.render :my_block do %>
  Hello
<% end %>
```

```haml
- wrapper = Proc.new do |b|
  %div= b.call
- blocks.define :my_block,
  wrapper: wrapper
= blocks.render :my_block do
  Hello
```

```ruby
# where builder is an instance
#  of Blocks::Builder
wrapper = Proc.new do |b|
  builder.content_tag :div, &b
end

builder.define :my_block,
  wrapper: wrapper
builder.render :my_block do
  "Hello"
end
```

> The above code will output the following

```html
<div>Hello</div>
```