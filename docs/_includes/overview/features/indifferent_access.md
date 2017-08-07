Let's jump right in with a relatively minor but important difference. The Blocks gem does not care whether the name of your Block is a String or a Symbol; it treats both as the same. So whereas using content_for with yield will require that the name matches identically, Blocks will handle the mismatch in Symbol and String:

```erb
<% blocks.define :my_content, partial: "my_partial" %>
<%= blocks.render "my_content" %>

=> Will output the contents of my_partial
```

```erb
<% content_for :my_content do %>
  My content
<% end %>
<%= yield "my_content" %>

=> Won't produce output
```

```erb
<% blocks.define "my_other_content" do %>
  My other content
<% end %>
<%= blocks.render :my_other_content %>
=> Will output "My other content"
```

```erb
<% content_for "my_other_content" do %>
  My content
<% end %>
<%= yield :my_other_content" %>

=> Won't produce output
```