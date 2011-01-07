Gem::Specification.new do |s|
  s.name = "blocks"
  s.authors = ["Andrew Hunter", "Todd Fisher"]
  s.version = "1.0.0"
  s.date    = '2011-01-07'
  s.description = %q{content_for with parameters, with advanced options such as a table generator (table_for)}
  s.email       = "andrew@captico.com"
  s.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  s.files = ["lib/blocks/builder.rb", "lib/blocks/container.rb", "lib/blocks/engine.rb", "lib/blocks/list_for.rb", "lib/blocks/table_for.rb", "lib/blocks.rb", "app/helpers/blocks/helper_methods.rb", "app/views/blocks/_list.html.erb", "app/views/blocks/_table.html.erb", "README.rdoc", "LICENSE"]
  s.require_paths = ['lib', 'app']
  s.rubyforge_project = 'blocks'
  s.homepage = 'https://github.com/hunterae/blocks'
  s.summary = %q{content_for with parameters, with advanced options such as a table generator (table_for)}
end
