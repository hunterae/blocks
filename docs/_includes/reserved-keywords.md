# Reserved Keywords

Whether defining a block, defining options for a block, rendering a block, registering hooks for a block, configuring global options for Blocks, or initializing an instance of a Blocks::Builder, there are certain keywords which are reserved for specific purposes:

## "collection" and "as" and "object" and "current_index"

"collection" is used to designate a collection for a block. When the block is rendered, it will be rendered for each item in the collection, and the "collection" option will be extracted from the options hash.

"as" is used to give each item in the collection an alias as it is being iterated over. "as" will default to "object", meaning that "object" becomes a reserved keyword by default. If "as" is set to some other value, whatever that value is will become a reserved keyword for that block.

"current_index" will be a zero-based index of the current item's position within the collection.

## "with"

"with" is used to specify the proxy render strategy, where its value is name of the other block to be rendered in its place.

## "partial"

"partial" is used to specify the Rails partial render strategy, where its value is the Rails partial to render.

### Other Reserved Keywords when using a partial

http://www.rubymagic.org/posts/ruby-and-rails-reserved-words

## "block"

"block" can be used to specify the Ruby block render strategy, where its value is the Ruby block to render. This is an alternative to specifying the block using the "do ... end" syntax.

## "defaults"

"defaults", if specified, must have its value be a hash. These represent default options, which are given a lower precedence than standard options when merging options.

## "runtime"

"runtime", if specified, must have its value be a hash. These represent runtime options, which are given a higher precedence than standard options when merging options.

## "builder" and "builder_variable"

"builder" will be the default variable name given to the instance of the Blocks::Builder passed to a partial that triggered the call to render to the possible. The "builder" can be used to invoke Blocks functionality within the partial on a shared instance of a Blocks::Builder.

The name "builder" can be overridden by specifying a value in "builder_variable".

## Wrappers

### "wrap_all"

Indicates that a wrapper will wrap around any wrap_each wrappers.

### "wrap_each" / "outer_wrapper"

Indicates that a wrapper will wrap around a block and any around, before, after, surround, prepend, and append hooks for that block.

### "wrap_with" / "wrap" / "wrapper" / "inner_wrapper"

Indicates that a wrapper will wrap around a block and any surround, prepend, and append hooks for that block.

## "parent_runtime_context"

Passed internally within the Blocks gem as a parent Blocks::RuntimeContext when calculating the Blocks::RuntimeContext for a hook or wrapper for a block.
