Gem::Specification.new do |s|
  s.name = "blocks"
  s.authors = ["Andrew Hunter", "Todd Fisher"]
  s.version = "0.3"
  s.date    = '2010-12-06'
  s.description = %q{Blocks makes it easy to create advanced ERB helpers}
  s.email       = "andrew@captico.com"
  s.extra_rdoc_files = ["LICENSE", "README"]
  s.files = ["lib/blocks/context.rb", "lib/blocks/engine.rb", "lib/blocks/table_for.rb", "lib/blocks.rb", "app/helpers/blocks/helper.rb", "app/views/blocks/tables/_table.html.erb", "README", "LICENSE"]
  s.require_paths = ['lib', 'app']
  s.rubyforge_project = 'blocks'
  s.homepage = 'http://blocks.rubyforge.org/'
  s.summary = %q{blocks makes erb fun again}
end
