# frozen_string_literal: true

require_relative "lib/xposedornot/version"

Gem::Specification.new do |spec|
  spec.name          = "xposedornot"
  spec.version       = XposedOrNot::VERSION
  spec.authors       = ["XposedOrNot"]
  spec.email         = ["deva@xposedornot.com"]

  spec.summary       = "Ruby client library for the XposedOrNot data breach API"
  spec.description   = "A Ruby gem for interacting with the XposedOrNot API to check email " \
                        "breaches, password exposure, and breach analytics. Supports both the " \
                        "free and commercial Plus API."
  spec.homepage      = "https://xposedornot.com"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"]        = spec.homepage
  spec.metadata["source_code_uri"]     = "https://github.com/XposedOrNot/XposedOrNot-Ruby"
  spec.metadata["changelog_uri"]       = "https://github.com/XposedOrNot/XposedOrNot-Ruby/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    Dir["{lib}/**/*", "LICENSE", "README.md"]
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-retry", "~> 2.0"
  spec.add_dependency "digest-keccak", "~> 1.3"
end
