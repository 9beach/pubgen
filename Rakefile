require 'rake'
require 'rake/testtask'

task :default => [:test_units]
Rake::TestTask.new('test_units') do |t|
  t.libs << %w[lib test]
  t.pattern = 'test/test*.rb'
  t.warning = true
end

