# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ask_bot/version'

Gem::Specification.new do |spec|
  spec.name          = "ask_bot"
  spec.version       = AskBot::VERSION
  spec.authors       = ["Austin Kahly"]
  spec.email         = ["austin@wantable.com"]

  spec.summary       = %q{Ask Bot API For Slack}
  spec.description   = %q{A bot to quote people with}
  spec.homepage      = "http://www.github.com/wantable"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
