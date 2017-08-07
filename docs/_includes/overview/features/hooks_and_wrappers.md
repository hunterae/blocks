In Rails, when you make multiple content_for calls with the same block name, and then yield to that block name, it outputs the concatenated content of the content_for blocks in the order in which they were defined:

```erb
<% content_for :hello do %>
  Hello 1,
<% end %>
<% content_for :hello do %>
  Hello 2,
<% end %>
<% content_for :hello do %>
  Hello 3
<% end %>

<%= yield :hello %>

<!-- Outputs Hello 1, Hello 2, Hello 3 -->
```

Blocks takes this concept one step further by giving the programmer an enormous degree of freedom in determining where and how content is rendered. It does so by providing a series of hooks and wrappers that render additional code in relation to the Block being rendered.

This gives the programmer the ability to define content that is prepended, appended, surrounding, before, after, around, before_all, and after_all the results of rendering the actual Block. When a collection is involved, there is also before_each, after_each, and around_each. This functionality is achieved through the use of Hooks.

Here's the above code translated into Blocks syntax:

```erb
<% blocks.append :hello do %>
  Hello 1,
<% end %>
<% blocks.append :hello do %>
  Hello 2,
<% end %>
<% blocks.append :hello do %>
  Hello 3
<% end %>
<%= blocks.render :hello %>

<!-- Outputs Hello 1, Hello 2, Hello 3 -->
```

While Rails will render multiple content_for calls with the same name in order, Blocks gives the programmer the ability to define relative content to be prepended, appended, surrounding, before, after, around, before_all, after_all while rendering the content block. When a collection is involved, there is also before_each, after_each, and around_each. This functionality is achieved through the use of Hooks.

There are three different types of hooks, and three levels for each of the types of hooks (making a total of nine different hooks). The three types are: before, after, and around hooks. They may exist at three different levels: in relation to all rendered content, in relation to a single item in a collection being rendered, and in relation to the actual content of the Block being rendered. The levels will become more clear as we proceed.

Hooks work similar to the way that Rails does ActionController filters; before hooks render code before the Block, after hooks render code after the Block, and around hooks render code around the Block. The level of the hook determines exactly where the code gets rendered in relation to the Block.

Multiple hooks may be defined of the same type. If they are append, after, or after_all hooks, the order in which they are rendered is the same as the order in which they are defined.

All other hooks will render in reverse order. The idea behind this is that if I define a before hook, and then define another before hook, the second before hook actually renders before the first before hook. It's like saying, "before some code, render this, and before that, render this". Likewise, defining an around hook will render around something, a second around hook will render around the first around hook, etc.

Like defining a Block, hooks can be defined as Ruby blocks, Rails partials, or Proxies. Multiple different hooks may be defined for the same Block.

```erb
<% blocks.prepend :my_block do %>
  Prepended content
<% end %>

<% blocks.before :my_block, partial: "some_partial" %>

<% blocks.after :my_block, with: :some_proxy_block %>
```



BEFORE HOOKS





The complete list of Hooks and Wrappers is as follows:

Hook Name	Where content Renders	Render order	Allows multiples?
before_all	Renders before all other content, hooks, and wrappers	Reverse order	Yes
around_all	Renders code around all other hooks and wrappers with the exception of the before_all and after_all hooks	Reverse order	Yes
wrap_all	Renders code around all other content with the exception of before_all, after_all, and around_all hooks	N/A	No
wrap_each	Renders around each item in a collection (the absence of a collection will treat the rendering as a collection with a single item)	N/A	No
around	Renders code around the combination of the before hooks, the wrapper, the surround hooks, the prepend hooks, the Block content, the append hooks, and the after hooks	Reverse order	Yes
before	Renders code immediately before the combination of the wrapper content, the surround hooks, the prepend hooks, the Block content, and the append hooks	Reverse order	Yes
wrapper	Renders code around the combination of the surround hooks, the prepend hooks, the Block content, and the append hooks	N/A	No
surround	Renders code around the combination of the prepend hooks, the Block content, and the append Hooks.	Reverse order	Yes
prepend	Renders code immediately prior to the Block content itself	Reverse order	Yes
append	Renders code immediately after the Block content itself	In order	Yes
after	Renders code immediately after the combination of the wrapper content, the surround hooks, the prepend hooks, the Block content, and the append hooks	In order	Yes
after_all	Renders code after all other content, hooks, and wrappers	In order	Yes
Graphically, this will look something like this (without a collection):

blockrendering-blockrenderingor with a collection:







blockrendering-collectionrendering

EXAMPLES

```erb
<% blocks.append :my_block do %>
  Append 1;
<% end %>
<% blocks.append :my_block do %>
  Append 2;
<% end %>
<% blocks.append :my_block do %>
  Append 3
<% end %>

<%= blocks.render :my_block do %>
  Content
<% end %>
<!-- Outputs Content Append 1; Append 2; Append 3 -->
<% blocks.prepend :my_block do %>
  Prepend 1;
<% end %>
<% blocks.prepend :my_block do %>
  Prepend 2;
<% end %>
<% blocks.prepend :my_block do %>
  Prepend 3;
<% end %>

<%= blocks.render :my_block do %>
  Content
<% end %>
<!-- Outputs Prepend 3; Prepend 2; Prepend 1; Content -->
```

```erb
<% blocks.around :my_block do |content_block| %>
  First around call<br>
  <%= content_block.call %>
  End of first around call<br>
<% end %>

<% blocks.around :my_block do |content_block| %>
  Second around call<br>
  <%= content_block.call %>
  End of second around call<br>
<% end %>

<% blocks.around :my_block do |content_block| %>
  Third around call<br>
  <%= content_block.call %>
  End of third around call<br>
<% end %>

<%= blocks.render :my_block do %>
  Content<br>
<% end %>

<!-- Outputs:
Third around call
Second around call
First around call
Content
End of first around call
End of second around call
End of third around call
-->
```

WRAPPERS

Wrappers work almost identically to around hooks with the exception that there may be multiple hooks of the same type but only a single wrapper of a particular type. There are three types of wrappers, one for each of the levels mentioned above.

Wrappers are like Hooks but they are singular; i.e. only a single wrapper of a given type may exist for a Block. There are three different wrapper types: wrap_all, wrap_each, and wrapper.