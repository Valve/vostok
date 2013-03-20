# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vostok/version'

Gem::Specification.new do |spec|
  spec.name          = "vostok"
  spec.version       = Vostok::VERSION
  spec.authors       = ["Valentin Vasilyev"]
  spec.email         = ["iamvalentin@gmail.com"]
  spec.description   = %q{Sick pg import}
  spec.summary       = %q{Sick pg import}
  spec.homepage      = "https://github.com/Valve/vostok"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "pg"
  
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
