# Installation & Prerequisites

Blocks requires Rails 3.0 or greater and Ruby 2.0 or greater.

It has been tested with Ruby 2.0.0 through 2.5.1 (as well as ruby-head), and Rails 3.0 - 5.2 (as well as Edge Rails)

```
gem 'blocks'
```

<aside class="notice">
Add this to your Gemfile:
</aside>

```shell
bundle install
```

<aside class="notice">
Then run this from your project directory command line:
</aside>

<aside class="success">
In most cases, this will be all you need to do. The "blocks" helper method is now available within your Rails views
</aside>

{% highlight ruby %}
if !Object.respond_to?(:yaml_as)
  class Object
    def self.yaml_as(*args)
      yaml_tag(*args)
    end
  end
end
{% endhighlight %}

<aside class="warning">
To get Blocks working for Rails 3.0 with a Ruby version of 2.5 or greater, use the following patch:
</aside>