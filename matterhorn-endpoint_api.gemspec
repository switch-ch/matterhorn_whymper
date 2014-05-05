# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'matterhorn/endpoint_api/version'

Gem::Specification.new do |spec|
  spec.name          = "matterhorn-endpoint_api"
  spec.version       = Matterhorn::EndpointApi::VERSION
  spec.authors       = ["Daniel Fritschi"]
  spec.email         = ["daniel.fritschi@switch.ch"]
  spec.summary       = %q{Matterhorn Enpoint API}
  spec.description   = %q{This Enpoint API is desind to write some ruby scripts against the Matterhorn}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "multipart-post"
  spec.add_runtime_dependency "net-http-digest_auth", "~> 1.4"
  spec.add_runtime_dependency "nokogiri"
  
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
