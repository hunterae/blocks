Gem::Specification.new do |s|
  s.name = "blocks"
  s.authors = ["Andrew Hunter", "Todd Fisher"]
  s.version = "0.9"
  s.date    = '2010-12-21'
  s.description = %q{content_for with parameters, with advanced options such as a table generator (table_for)}
  s.email       = "andrew@captico.com"
  s.extra_rdoc_files = ["LICENSE", "README"]
  s.files = ["lib/blocks/builder.rb", "lib/blocks/container.rb", "lib/blocks/engine.rb", "lib/blocks/list_for.rb", "lib/blocks/table_for.rb", "lib/blocks.rb", "app/helpers/blocks/helper_methods.rb", "app/views/blocks/_list.html.erb", "app/views/blocks/_table.html.erb", "README", "LICENSE"]
  s.require_paths = ['lib', 'app']
  s.rubyforge_project = 'blocks'
  s.homepage = 'http://blocks.rubyforge.org/'
  s.summary = %q{content_for with parameters, with advanced options such as a table generator (table_for)}
end
