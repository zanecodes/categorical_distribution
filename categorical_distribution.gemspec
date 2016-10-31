# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'categorical_distribution/version'

Gem::Specification.new do |spec|
  spec.name          = "categorical_distribution"
  spec.version       = CategoricalDistribution::VERSION
  spec.authors       = ["Zane Geiger"]
  spec.email         = ["zanecodes@gmail.com"]

  spec.summary       = "Generates values from a categorical probability distribution in O(1) using Vose's Alias Method."
  spec.homepage      = "https://github.com/zanecodes/categorical_distribution"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 1.9'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
