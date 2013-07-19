require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')

# If you want to make this the default task
task :default => :spec

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "blocks"
    gemspec.summary = "Blocks is an intricate way of rendering blocks of code, while combining some of the best features of content blocks and partials, and adding several new features that go above and beyond what a simple content_for with yield or a render :partial is capable of doing."
    gemspec.description = "Blocks goes beyond blocks and partials"
    gemspec.email = "hunterae@gmail.com"
    gemspec.homepage = "http://github.com/hunterae/blocks"
    gemspec.authors = ["Andrew Hunter"]
    gemspec.files =  FileList["[A-Z]*", "{lib,spec,rails}/**/*"] - FileList["**/*.log", "Gemfile", "Gemfile.lock"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end