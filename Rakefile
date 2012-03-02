require 'rake'
require 'rake/testtask'

task :default => [:test_bad_options]

Rake::TestTask.new('test_units') do |t|
  t.libs << %w[lib test]
  t.pattern = 'test/test*.rb'
  t.warning = true
  # t.verbose = true
end

$tmpdir = '.rake_test'

def bad_options_call(cmd)
  %x[#{cmd} > /dev/null 2>&1]
  raise "Not failed: #{cmd}" if $?.success?
end

task :test_bad_options => :test_toc_2 do |t|
  $stdout << "# task: #{t} => "
  bad_options_call("bin/pubgen -t x.html -o a.epub")
  bad_options_call("bin/pubgen -t x.html -m")
  bad_options_call("bin/pubgen -o x.epub -m")
  bad_options_call("bin/pubgen")
  bad_options_call("bin/pubgen -t x.html")
  bad_options_call("bin/pubgen -o")
  bad_options_call("bin/pubgen -t")
  puts "done!"
end

def sh_exec(cmd)
  %x[#{cmd}]
  raise "Failed: #{cmd}" unless $?.success?
end

task :test_toc_2 => :test_toc_1 do |t|
  $stdout << "# task: #{t} => "
  sh_exec("mkdir -p #{$tmpdir}")
  sh_exec("cp test/toc_2/couchdb.html #{$tmpdir}")
  sh_exec("touch #{$tmpdir}/foreword.html #{$tmpdir}/preface.html " << 
    "#{$tmpdir}/why.html #{$tmpdir}/consistency.html #{$tmpdir}/tour.html " <<
    "#{$tmpdir}/api.html")
  sh_exec("bin/pubgen -t #{$tmpdir}/couchdb.html #{$tmpdir} > #{$tmpdir}/.o.yml")
  sh_exec("diff test/toc_2/couchdb.yml #{$tmpdir}/.o.yml")
  sh_exec("rm -rf #{$tmpdir}")
  puts "done!"
end

task :test_toc_1 => :test_output do |t|
  $stdout << "# task: #{t} => "
  sh_exec("mkdir -p #{$tmpdir}")
  sh_exec("bin/pubgen -t test/toc_1/will_oldham.html test/toc_1/ > #{$tmpdir}/.o.yml")
  sh_exec("diff test/toc_1/will_oldham.yml #{$tmpdir}/.o.yml")
  sh_exec("rm -rf #{$tmpdir}")
  puts "done!"
end

task :test_output => :test_units do |t|
  $stdout << "# task: #{t} => "
  sh_exec("mkdir -p #{$tmpdir}/contents")
  sh_exec("mkdir -p #{$tmpdir}/images")
  sh_exec("cp test/output/will_oldham.yml #{$tmpdir}")
  sh_exec("touch #{$tmpdir}/contents/a.html #{$tmpdir}/contents/b.html " <<
    "#{$tmpdir}/images/1.jpg #{$tmpdir}/images/2.jpg " <<
    "#{$tmpdir}/images/3.jpg #{$tmpdir}/images/cover.jpg " <<
    "#{$tmpdir}/style.css")
  sh_exec("bin/pubgen #{$tmpdir}/will_oldham.yml -o #{$tmpdir}/a.epub > /dev/null")
  sh_exec("rm -rf #{$tmpdir}")
  puts "done!"
end
