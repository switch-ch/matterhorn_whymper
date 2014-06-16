# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'matterhorn_whymper/version'

Gem::Specification.new do |spec|
  spec.name          = "matterhorn_whymper"
  spec.version       = MatterhornWhymper::VERSION
  spec.authors       = ["Daniel Fritschi"]
  spec.email         = ["daniel.fritschi@switch.ch"]
  spec.summary       = %q{Ruby wrapper around the Matterhorn Endpoint API}
  spec.description   = %q{This Ruby wrapper is designed to write some ruby scripts against the
                          Matterhorn Endpoint API}
  spec.homepage      = "https://github.com/switch-ch/matterhorn_whymper"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "multipart-post", "~> 2.0"
  spec.add_runtime_dependency "net-http-digest_auth", "~> 1.4"
  spec.add_runtime_dependency "nokogiri", "~> 1.6"
  spec.add_runtime_dependency "mime-types", "> 1.25"
  
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.3"
  spec.add_development_dependency "rspec", "~> 2.14"
end
