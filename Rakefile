# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

namespace :test do
  Rake::TestTask.new(:webserver) do |t|
    t.libs << "test"
    t.test_files = FileList['test/webserver/*_test.rb']
    t.verbose = false
  end
end
