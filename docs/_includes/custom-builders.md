# Custom Builders

{% highlight ruby %}
class MyCustomBuilder < Blocks.builder_class
  def initialize(view, options={})
    super view, options

    # Additional initialization /
    #  block definitions could happen here
  end
end
{% endhighlight %}

{% highlight ruby %}
# From a controller action:
builder = MyCustomBuilder.new(view_context)
builder.define :some_block do
  "Hello"
end
builder.render :some_block
{% endhighlight %}

> This will output "Hello"

Blocks::Builder is the main class for storing information about block definitions and their corresponding hooks and wrappers.

Wherever a Block is defined, or a hook is registered for a Block, or a block is skipped, or a Block is rendered, all actions will be executed on an instance of Blocks::Builder.

When the "blocks" keyword is called from the view for the first time, it will instantiate a new instance of a Blocks::Builder (or a subclass of Blocks::Builder if the Blocks.builder_class is configured to something else - [See Configuring the Builder Class](#configuring-the-builder-class)).

A custom builder is just a subclass of Blocks::Builder. Instead of extending the Blocks::Builder class directly though, it is usually better to extend Blocks.builder_class (which will be Blocks::Builder unless it has been configured to something else). The one general exception to this rule is on the class that is configured to be the Blocks.builder_class - this should extend Blocks::Builder directly.

If #initialize is overridden in the subclass, it must, at a minimum call super with a reference to the view or view_context, and optionally, the init options hash.

## Custom Builders with Helper Methods

{% highlight ruby %}
class MyCustomBuilder < Blocks.builder_class
  def tag(*args, &block)
    options = args.extract_options!

    wrapper_html = if options.is_a?(Blocks::RuntimeContext)
      wrapper_option =
        options[:wrapper_option] || :wrapper_html
      options[wrapper_option] || {}
    else
      options
    end

    wrapper_tag = options[:wrapper_tag]
    if !wrapper_tag
      first_arg = args.first
      wrapper_tag = if first_arg.is_a?(String) || first_arg.is_a?(Symbol)
        first_arg
      else
        :div
      end
    end

    content_tag wrapper_tag, wrapper_html, &block
  end
end
{% endhighlight %}

```erb
<% builder = MyCustomBuilder.new(self) %>
<%= builder.render :my_block,
  wrapper: :tag,
  wrapper_tag: :h2,
  wrapper_html: { class: 'text-muted' } do %>
  Hello
<% end %>

<!-- OR -->

<%= builder.tag :h2, class: 'text-muted' do %>
  Hello
<% end %>
```

```haml
- builder = MyCustomBuilder.new(self)
= builder.render :my_block,
  wrapper: :tag,
  wrapper_tag: :h2,
  wrapper_html: { class: 'text-muted' } do
  Hello

#- OR

= builder.tag :h2, class: 'text-muted' do
  Hello
```

```ruby
builder = MyCustomBuilder.new(self)
builder.render :my_block,
  wrapper: :block_wrapper,
  wrapper_tag: :h2,
  wrapper_html: { class: 'text-muted' } do
  "Hello"
end

# OR

builder.tag :h2, class: 'text-muted' do
  "Hello"
end
```

> This will produce the following output:

```html
<h2 class='text-muted'>Hello</h2>
```

One of the primary reasons one might want to create a custom builder is to provide helper methods that are isolated within the builder. These helper methods may be invoked directly on the builder object, or indirectly by using a proxy or hook or wrapper.

In the example to the right, tag is declared as a method (which is almost a direct port over of the "block_wrapper" block defined in the [Templating Example for Bootstrap Cards](#extracting-out-the-wrappers) it was defined as a Block). The code has been slightly modified to allow the method to be called directly from the builder, or indirectly as a wrapper or hook for a Block.

<aside class="notice">
  At this time, it is not possible to proxy to a builder method (by using the "with" keyword) that expects / allows a block as an argument (i.e. this wouldn't be possible: 'builder.render with: :tag do "Hello" end'. This will likely change in future versions).
</aside>

<aside class="notice">
  If the method is called indirectly, either because it is registered as a hook or wrapper for a block, the options hash that is sent in to the method will be an instance of a Blocks::RuntimeContext. If the method is called directly on the builder, the options hash will be whatever is directly passed in or default to an empty hash.
</aside>