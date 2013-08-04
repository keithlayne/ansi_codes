# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ansi_codes/version'

Gem::Specification.new do |spec|
  spec.name          = "ansi_codes"
  spec.version       = AnsiCodes::VERSION
  spec.authors       = ["Keith Layne"]
  spec.email         = ["klayne@trupointpartners.com"]
  spec.description   = %q{ANSI state and county codes.}
  spec.summary       = %q{}
  spec.homepage      = "https://github.com/keithlayne/ansi_codes"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
