# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'quickbase_logger/version'

Gem::Specification.new do |spec|
  spec.name          = "quickbase_logger"
  spec.version       = QuickbaseLogger::VERSION
  spec.authors       = ["Cullen Jett"]
  spec.email         = ["cullenjett@gmail.com"]
  spec.summary       = "Use Quickbase tables as a logging platform"
  spec.description   = "QuickbaseLogger offers a configurable way to use the Intuit QuickBase platform as a way to log Ruby script information."
  spec.homepage      = "https://github.com/cullenjett/quickbase_logger"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency "quickbase_record", ">= 0.4.5"
end
