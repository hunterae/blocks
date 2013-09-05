require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new('spec')

# If you want to make this the default task
task :default => :spec

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "blocks"
  gem.homepage = "http://github.com/hunterae/blocks"
  gem.license = "MIT"
  gem.summary = "Blocks is an intricate way of rendering blocks of code and adding several new features that go above and beyond what a simple content_for with yield is capable of doing."
  gem.description = "Blocks goes beyond blocks and partials"
  gem.email = "hunterae@gmail.com"
  gem.authors = ["Andrew Hunter"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new