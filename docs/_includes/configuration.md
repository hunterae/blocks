# Configuration

Blocks is customized by adding an initializer to config/initializers directory called blocks.rb.

{% highlight erb %}
Blocks.configure do |config|
  # Configuration code goes here
end
{% endhighlight %}

## Configuring Global Options

Global Options are merged into the set of options generated when rendering a block or hook or wrapper for a block. They are given the lowest precedence when merging options.

### Global Runtime Options
{% highlight erb %}
Blocks.configure do |config|
  config.
    global_options_set.
    add_options runtime: {
      a: 1, b: 2
    }
end
{% endhighlight %}

### Global Standard Options
{% highlight erb %}
Blocks.configure do |config|
  config.
    global_options_set.
    add_options a: 1, b: 2
end
{% endhighlight %}

### Global Default Options
{% highlight erb %}
Blocks.configure do |config|
  config.
    global_options_set.
    add_options defaults: {
      a: 1, b: 2
    }
end
{% endhighlight %}

## Configuring Caller ID
{% highlight erb %}
Blocks.configure do |config|
  config.lookup_caller_location = true
end
{% endhighlight %}

Caller ID is a debugging feature that is turned off by default, and should really only ever be turned on in Development mode and perhaps Test mode. It is enabled by running the configuration code to the right. Setting this flag to true will noticeably affect the execution speed of page rendering. This is because for every option that is added to a Block, a Proxy to a Block, or when rendering a block, the code will figure out what line of code triggered the setting of that option.

## Configuring the Builder Class
{% highlight erb %}
Blocks.configure do |config|
  config.builder_class = LayoutBuilder
end
{% endhighlight %}

The Builder Class is Blocks::Builder by default, but can be changed to something else using this configuration option. Whatever it is changed to, the new class should be a subclass of Blocks::Builder. Configuring the Builder Class is useful when you want to add in block definitions or shared functionality for the entire application.