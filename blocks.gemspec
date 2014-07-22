# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blocks/version'

Gem::Specification.new do |spec|
  spec.name          = "blocks"
  spec.version       = Blocks::VERSION
  spec.authors       = ["Andrew Hunter"]
  spec.email         = ["hunterae@gmail.com"]
  spec.summary       = %q{Blocks goes beyond blocks and partials}
  spec.description   = %q{Blocks goes beyond blocks and partials}
  spec.homepage      = "http://github.com/hunterae/blocks"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 3.0.0"
  spec.add_dependency "call_with_params", "~> 0.0.2"
  spec.add_dependency "hashie"

  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "debugger"
end
