# Blocks

The Blocks gem is many things.

It acts as:

* a container for reusable blocks of code and options
* a common interface for rendering code, whether the code was defined previously in Ruby blocks, Rails partials, or proxies to other blocks of code
* a series of hooks and wrappers that can be utilized to render code before, after, and around other blocks of code, as well as before each, after each, and around each item in a collection
* a templating utility for easily building reusable and highly customizable UI components
* a means for DRYing up oft-repeated code in your layouts and views
* a simple mechanism for changing or skipping the rendering behavior for particular blocks of code

Essentially, this all boils down to the following: Blocks makes it easy to define blocks of code that can be rendered either verbatim or with replacements and modifications at some later point in time.

[![Build Status](https://travis-ci.org/hunterae/blocks.svg)](https://travis-ci.org/hunterae/blocks)

## Usage

Please checkout the documentation for the Blocks gem here: http://hunterae.github.io/blocks/.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'blocks'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blocks

## Development

After checking out the repo, run `bundle install` (and possibly `gem install bundler` if you don't already have bundler installed) to install dependencies. Then, run `rake` to run the tests. You can also run `bundle console` for an interactive prompt that will allow you to experiment.

## Documentation

The documentation is generated using [Jekyll](https://jekyllrb.com/) and hosted on the [Blocks gh-pages branch](https://github.com/hunterae/blocks/tree/gh-pages).

The static content is generated based on the source code within the [docs directory](https://github.com/hunterae/blocks/tree/master/docs).

To run the documentation locally or make changes for a corresponding pull request, follow the steps in the [Development Section above](#development). Then run `jekyll serve` and visit http://127.0.0.1:4000/blocks/.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hunterae/blocks.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

