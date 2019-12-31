## The :content_tag Block

> According to Bootstrap's documentation, a standard card has the following markup:

The :content_tag block is more or less a direct wrapper around [ActionView's content_tag method](https://apidock.com/rails/ActionView/Helpers/TagHelper/content_tag).
However, by defining it as a block, it may be used in several useful ways.

### As the definition for a block

```erb
<% blocks.define :title, with: :content_tag, tag: :h1, html: { style: "color: red" } %>
<%= blocks.render :title do %>
  My Title
<% end %>
```

```haml
- blocks.define :title, with: :content_tag, tag: :h1, html: { style: "color: red" }
= blocks.render :title do
  My Title
```

```ruby
builder = Blocks::Builder.new(view_context)
builder.define :title, with: :content_tag, tag: :h1, html: { style: "color: red" }
# Since no overrides block is provided, this
#  call is synonymous with:
builder.render :title do
  "My Title"
end
```

> The output from running the code will be:
{% highlight html %}
<h1 style="color: red">
  My Title
</h1>
{% endhighlight %}

When used as the definition for a block (using the with keyword), you may choose to specify the tag to use or any html options to be applied to the tag.
Then, you can either provide the definition a block of its own or supply as a render option when calling render.

### As a wrapper or a surrounding hook for a block

