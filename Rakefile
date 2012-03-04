require 'rake'
require 'rake/testtask'

task :default => [:test_bad_options]

Rake::TestTask.new('test_units') do |t|
  t.libs << %w[lib test]
  t.pattern = 'test/test*.rb'
  t.warning = true
  # t.verbose = true
end

def sh_echo_off(cmd)
  %x[#{cmd}]
  raise "Failed: #{cmd}" unless $?.success?
end

def sh_echo_off_failure(cmd)
  %x[#{cmd} > /dev/null 2>&1]
  raise "Not failed: #{cmd}" if $?.success?
end

$tmpdir = '.rake_test'

task :test_bad_options => :test_toc_2 do |t|
  $stdout << "# task: #{t} => "
  sh_echo_off_failure("bin/pubgen -t x.html -o a.epub")
  sh_echo_off_failure("bin/pubgen -t x.html -m")
  sh_echo_off_failure("bin/pubgen -o x.epub -m")
  sh_echo_off_failure("bin/pubgen")
  sh_echo_off_failure("bin/pubgen -t x.html")
  sh_echo_off_failure("bin/pubgen -o")
  sh_echo_off_failure("bin/pubgen -t")
  puts "done!"
end

task :test_toc_2 => :test_toc_1 do |t|
  $stdout << "# task: #{t} => "
  sh_echo_off("mkdir -p #{$tmpdir}")
  sh_echo_off("cp test/toc_2/couchdb.html #{$tmpdir}")
  sh_echo_off("touch #{$tmpdir}/foreword.html #{$tmpdir}/preface.html " << 
    "#{$tmpdir}/why.html #{$tmpdir}/consistency.html #{$tmpdir}/tour.html " <<
    "#{$tmpdir}/api.html")
  o_yml = "#{$tmpdir}/.out.yml"
  sh_echo_off("bin/pubgen -t #{$tmpdir}/couchdb.html #{$tmpdir} > #{o_yml}")
  sh_echo_off("diff test/toc_2/couchdb.yml #{o_yml}")
  sh_echo_off("rm -rf #{$tmpdir}")
  puts "done!"
end

task :test_toc_1 => :test_output do |t|
  $stdout << "# task: #{t} => "
  sh_echo_off("mkdir -p #{$tmpdir}")
  o_yml = "#{$tmpdir}/.out.yml"
  sh_echo_off("bin/pubgen -t test/toc_1/will_oldham.html test/toc_1 > #{o_yml}")
  sh_echo_off("diff test/toc_1/will_oldham.yml #{o_yml}")
  sh_echo_off("rm -rf #{$tmpdir}")
  puts "done!"
end

task :test_output => :test_units do |t|
  $stdout << "# task: #{t} => "
  sh_echo_off("mkdir -p #{$tmpdir}/contents")
  sh_echo_off("mkdir -p #{$tmpdir}/images")
  sh_echo_off("cp test/output/will_oldham.yml #{$tmpdir}")
  sh_echo_off("touch #{$tmpdir}/contents/a.html #{$tmpdir}/contents/b.html " <<
    "#{$tmpdir}/images/1.jpg #{$tmpdir}/images/2.jpg " <<
    "#{$tmpdir}/images/3.jpg #{$tmpdir}/images/cover.jpg " <<
    "#{$tmpdir}/style.css")
  sh_echo_off("bin/pubgen #{$tmpdir}/will_oldham.yml -o #{$tmpdir}/a.epub " <<
    "> /dev/null")
  sh_echo_off("rm -rf #{$tmpdir}")
  puts "done!"
end

task :build_gem do
  sh "gem build pubgen.gemspec"
end

task :push_gem => :build_gem do
  $:.push File.expand_path("../lib", __FILE__)
  require "pubgen/version"
  sh "gem push pubgen-#{Pubgen::VERSION}.gem"
end

