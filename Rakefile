require 'bundler/setup'
require 'rake/testtask'

Bundler::GemHelper.install_tasks

# task :test do
#   require 'simplecov'
#   SimpleCov.start do
#     add_filter '/test/'
#     command_name 'minitest'
#   end
#   test_list = Rake::FileList.new('test/**/*rb').to_a
#   test_list.each do | fn |
#     $:.unshift 'lib'
#     require_relative fn
#   end
# end

Rake::TestTask.new(:test) do | t |
  test_list = Rake::FileList.new('test/**/*rb')
  test_list.exclude /((.*config.*)|(.*test_helper.*))/
  test_list.to_a
  # puts test_list.to_a

  t.libs << "test"
  t.test_files = test_list
end
