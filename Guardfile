notification :terminal_notifier if `uname` =~ /Darwin/

rspec_options = {
  cmd: "rspec",
  all_after_pass: false,
  all_on_start: false,
  failed_mode: :focus
}

guard :rspec, cmd: "bundle exec rspec" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/blocks/(.+)\.rb$})     { "spec" }
  watch(%r{^lib/blocks.rb$})           { "spec" }
  watch('spec/spec_helper.rb')         { "spec" }
end
