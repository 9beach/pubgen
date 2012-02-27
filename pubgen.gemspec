# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "pubgen/version"

Gem::Specification.new do |s|
  s.name                  = "pubgen"
  s.version               = Pubgen::VERSION
  s.platform              = Gem::Platform::RUBY
  s.author                = "9beach"
  s.email                 = ["9beach@gmail.com"]
  s.homepage              = "https://github.com/9beach/pubgen"
  s.files                 = `git ls-files`.split("\n")
  s.executables           = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.bindir                = 'bin'
  s.require_paths         = ["lib"]
  s.summary               = "command-line based epub generator"
  s.description           = "Pubgen is a simple command-line based epub generator. With a plain YAML, Pubgen generate the epub for you."
  s.add_dependency        "zipruby"
end
