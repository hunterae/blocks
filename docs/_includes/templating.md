# Templating

> Sample Syntax

```erb
<%= render_with_overrides partial:
  "PATH_TO_PARTIAL" do |builder| %>
  <!-- Perform overrides here
        using the builder.
        Whatever happens here
        happens first. -->
<% end %>
```

```haml
= render_with_overrides partial: "PATH_TO_PARTIAL" do |b|
  #- Perform overrides here using the builder.
  #- Whatever happens here happens first.
```

```ruby
builder = Blocks::Builder.new(view_context)
builder.render_with_overrides partial:
  "PATH_TO_PARTIAL" do |builder|
  # Perform overrides here
  #  using the builder.
  #  Whatever happens here
  #  happens first.
end
```

Templating is one of the most powerful concepts within the Blocks gem. It is the bedrock on which reusable UI components can be built.

A template is nothing more than a Rails partial (in future releases, this concept will likely expand to Ruby blocks as well) that has a reference to an instance of a Blocks::Builder object, and uses it to invoke Blocks functionality. It may consist of multiple block definitions, block render calls, block wrappers and hooks, and other content.

By default, a Blocks::Builder instance will be passed in as a variable called "builder", but this can be overridden by specifying the "builder_variable" option. When rendering this template, it should produce either a standard / default definition for your template or a sample output of your template complete with dummy data.

<aside class="warning">
  This functionality can be invoked on an existing instance of a Blocks::Builder, but this should be done with caution, as all block definitions will share a namespace. For this reason, it is usually best to invoke the functionality on a new instance of a Blocks::Builder.
</aside>

However, this standard / default / sample definition can be overridden at runtime with an overrides block that will execute before the template is rendered by the code that is rendering the template.

There are two ways to invoke this functionality, either using the #render_with_overrides method (also aliased as #with_template) that is injected into ActionView as a helper method, or by calling #render_with_overrides on an existing or new instance of a Blocks::Builder.

<img src="{{'/templating.png' | prepend: site.images_dir | prepend: '/'}}" />

{% include templating/bootstrap_4_cards.md %}