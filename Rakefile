BLOCKS_VERSION="0.1"

desc 'Generate gem specification'
task :gemspec do
  require 'erb'
  tspec = ERB.new(File.read(File.join(File.dirname(__FILE__),'lib','blocks.gemspec.erb')))
  File.open(File.join(File.dirname(__FILE__),'blocks.gemspec'),'wb') do|f|
    f << tspec.result
  end
end

desc 'Generate a gem file'
task :package => :gemspec do
  puts "Building version: #{BLOCKS_VERSION.inspect}"
  sh "gem build blocks.gemspec"
end
