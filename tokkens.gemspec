# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tokkens/version'

Gem::Specification.new do |spec|
  spec.name          = "tokkens"
  spec.version       = Tokkens::VERSION
  spec.authors       = ["wvengen"]
  spec.email         = ["dev-rails@willem.engen.nl"]
  spec.summary       = %q{Simple text to numbers tokenizer}
  spec.homepage      = "https://github.com/q-m/ruby-tokkens"
  spec.license       = "MIT"
  spec.description   = <<-EOD
    Tokkens makes it easy to apply a vector space model to text documents,
    targeted towards with machine learning. It provides a mapping between
    numbers and tokens (strings)
  EOD

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0'
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.5.0"
end
