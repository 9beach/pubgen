require 'rake'
require 'rake/testtask'

task :default => [:test_toc_2]

Rake::TestTask.new('test_units') do |t|
  t.libs << %w[lib test]
  t.pattern = 'test/test*.rb'
  t.warning = true
  t.verbose = true
end

$tmpdir = '.rake_test'

task :test_toc_2 => :test_toc_1 do
  mkdir_p $tmpdir
  cp "test/toc_2/couchdb.html", $tmpdir
  touch "#{$tmpdir}/foreword.html #{$tmpdir}/preface.html #{$tmpdir}/why.html\
    #{$tmpdir}/consistency.html #{$tmpdir}/tour.html \
    #{$tmpdir}/api.html".split(' ')
  sh "bin/pubgen -t #{$tmpdir}/couchdb.html #{$tmpdir} > #{$tmpdir}/.o.yml"
  sh "diff test/toc_2/couchdb.yml #{$tmpdir}/.o.yml"
  rm_rf $tmpdir
end

task :test_toc_1 => :test_output do
  mkdir_p $tmpdir
  sh "bin/pubgen -t test/toc_1/will_oldham.html test/toc_1/ > #{$tmpdir}/.o.yml"
  sh "diff test/toc_1/will_oldham.yml #{$tmpdir}/.o.yml"
  rm_rf $tmpdir
end

task :test_output => :test_units do
  mkdir_p $tmpdir
  mkdir_p "#{$tmpdir}/contents"
  mkdir_p "#{$tmpdir}/images"
  cp "test/output/will_oldham.yml", $tmpdir
  touch "#{$tmpdir}/contents/a.html #{$tmpdir}/contents/b.html \
    #{$tmpdir}/images/1.jpg #{$tmpdir}/images/2.jpg #{$tmpdir}/images/3.jpg \
    #{$tmpdir}/images/cover.jpg #{$tmpdir}/style.css".split(' ')
  sh "bin/pubgen #{$tmpdir}/will_oldham.yml -o #{$tmpdir}/a.epub > /dev/null"
  rm_rf $tmpdir
end
