# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'memory_usage_profiler/version'

Gem::Specification.new do |spec|
  spec.name          = "ruby-memory-usage-profiler"
  spec.version       = MemoryUsageProfiler::VERSION
  spec.authors       = ["TAGOMORI Satoshi"]
  spec.email         = ["tagomoris@gmail.com"]
  spec.description   = %q{Memory usage profiler for debugging of Ruby itself (and/or middlewares)}
  spec.summary       = %q{CRuby and linux memory usage profiler by @_ko1}
  spec.homepage      = "https://github.com/tagomoris/ruby-memory-usage-profiler"
  spec.license       = "Ruby's"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
