require "rake/testtask"

namespace :test do
  Rake::TestTask.new(:webserver) do |t|
    t.libs << "test"
    t.test_files = FileList['test/webserver/*_test.rb']
    t.verbose = false
  end
end
