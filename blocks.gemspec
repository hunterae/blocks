# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blocks/version'

Gem::Specification.new do |spec|
  spec.name          = "blocks"
  spec.version       = Blocks::VERSION
  spec.authors       = ["Andrew Hunter"]
  spec.email         = ["hunterae@gmail.com"]

  spec.summary       = %q{Blocks gives you total control over how your blocks of code render.}
  spec.description   = %q{Blocks gives you total control over how your blocks of code render.}
  spec.homepage      = "https://github.com/hunterae/blocks"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "terminal-notifier-guard", "~> 1.6.1"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "shoulda-matchers", "~> 3.1"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "haml"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 1.0.0"

  spec.add_dependency "call_with_params"
  spec.add_dependency "rails", ">= 3.0.0"
end
