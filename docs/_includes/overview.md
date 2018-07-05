# Overview

There are many ways to render content to the screen in web applications. Ruby on Rails offers a couple of default strategies right off the bat through its combination of ActionController, ActionView, and ERB templating language:

* Rendering content within an ActionView template (the controller action) and layout
* Pulling in additional content through rendering partials
* Capturing content from a block and outputting that content at some later point
* Calling a different method from the controller action which determines what and how to render

There are obviously additional means to render output, such as the redirect methods in a controller and rendering inline code, but generally speaking, most generated output come about through one of those above methods.

The approaches listed above can essentially be generalized as follows

* Rendering using a method
* Rendering fragments (using a Rails' partial)
* Storing content for later rendering (using a Ruby Block)
* Proxying to another source that knows what to / how to render

The Blocks gem attempts to take these four concepts and provide one common interface.

The reasoning behind this is simple.