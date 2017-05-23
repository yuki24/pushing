# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pushing/version'

Gem::Specification.new do |spec|
  spec.name          = "pushing"
  spec.version       = Pushing::VERSION
  spec.authors       = ["Yuki Nishijima"]
  spec.email         = ["mail@yukinishijima.net"]
  spec.summary       = %q{Push notification framework that does not hurt. finally.}
  spec.description   = %q{Pushing is like ActionMailer, but for sending push notifications.}
  spec.homepage      = "https://github.com/yuki24/pushing"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "actionpack", ">= 4.2.0"
  spec.add_dependency "actionview", ">= 4.2.0"
  spec.add_dependency "activejob", ">= 4.2.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "jbuilder"
end
