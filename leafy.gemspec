lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "leafy/core/version"

Gem::Specification.new do |spec|
  spec.name          = "leafy"
  spec.version       = Leafy::Core::VERSION
  spec.authors       = [""]
  spec.email         = [""]
  spec.summary       = "Port of Dropwizards metrics-core to pure ruby"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/leafy-metrics/leafy"
  spec.license       = "APL2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.2.0'

  spec.add_runtime_dependency "concurrent-ruby", "~> 1.0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.4"
end
