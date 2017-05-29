require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb'] - FileList['test/integration/**/*'] - ["test/railtie_test.rb"]
end

Rake::TestTask.new('test:integration') do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/integration/**/*_test.rb']
end

Rake::TestTask.new('test:isolated') do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = ["test/railtie_test.rb"]
end

task default: [:test, 'test:isolated']
