# Introduction

The [blocks gem](http://github.com/hunterae/blocks) is many things.

It acts as:

* a container for reusable blocks of code and options
* a common interface for rendering code, whether the code was defined previously in Ruby blocks, Rails partials, or proxies to other blocks of code
* a series of hooks and wrappers that can be utilized to render code before, after, and around other blocks of code, as well as before each, after each, and around each item in a collection
* a templating utility for easily building reusable and highly customizable UI components
* a means for DRYing up oft-repeated code in your layouts and views
* a simple mechanism for changing or skipping the rendering behavior for particular blocks of code

Essentially, this all boils down to the following: Blocks makes it easy to define blocks of code that can be rendered either verbatim or with replacements and modifications at some later point in time.

[![Build Status](https://travis-ci.org/hunterae/blocks.svg?branch=3-0-stable)](https://travis-ci.org/hunterae/blocks)