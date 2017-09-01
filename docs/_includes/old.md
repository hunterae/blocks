# This Looks Familiar

If you think this looks somewhat familiar, there's good reason for that. Any similarities you may notice with [Rails's content_for with yield](http://api.rubyonrails.org/classes/ActionView/Helpers/CaptureHelper.html#method-i-content_for) and [rendering partials in Rails](https://apidock.com/rails/ActionController/Base/render) are intentional (the proxying feature may even remind you of [Ruby's Forwardable Module](http://ruby-doc.org/stdlib-2.0.0/libdoc/forwardable/rdoc/Forwardable.html)). Part of the original reasoning for the creating this gem was to provide a common interface for rendering both Ruby blocks and Rails' partials.


Example of same code written with Blocks vs. Rails' content_for with yield:

```erb
<% blocks.define :my_content do %>
  My content to be rendered later
<% end %>

<%= blocks.render :my_content %>
```

```erb
<% content_for :my_content do %>
  My content to be rendered later
<% end %>

<%= yield :my_content %>
```

Example of same code written with Blocks vs. Rails' render partial:

```erb
<% blocks.define :my_content, partial: "my_partial" %>

<%= blocks.render :my_content %>
```

```erb
<%= render partial: "my_partial" %>
```

If the Blocks Gem ended there, it might even prove useful to a few people out there, but as we'll soon see, Blocks goes way beyond these enhancements.