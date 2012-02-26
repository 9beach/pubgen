# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name                  = "pubgen"
  s.version               = "0.1.2"
  s.platform              = Gem::Platform::RUBY
  s.author                = "9beach"
  s.email                 = ["9beach@gmail.com"]
  s.homepage              = "https://github.com/9beach/pubgen"
  s.files                 = `git ls-files`.split("\n")
  s.executables           = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.bindir                = 'bin'
  s.require_paths         = ["lib"]
  s.summary               = "command-line based epub generator"
  s.description           = "Pubgen is a simple command-line based epub generator. With the simple YAML file, Pubgen generate the epub file for you."
  s.add_dependency        "zipruby"
end
