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

