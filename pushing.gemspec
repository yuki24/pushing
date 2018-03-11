# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pushing/version'

Gem::Specification.new do |spec|
  spec.name          = "pushing"
  spec.version       = Pushing::VERSION
  spec.authors       = ["Yuki Nishijima"]
  spec.email         = ["yk.nishijima@gmail.com"]
  spec.summary       = %q{Push notification framework that does not hurt}
  spec.description   = %q{Finally, push notification framework that does not hurt. Currently supports Android (FCM) and iOS (APNs)}
  spec.homepage      = "https://github.com/yuki24/pushing"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency "actionpack", ">= 4.2.0"
  spec.add_dependency "actionview", ">= 4.2.0"
  spec.add_dependency "activejob", ">= 4.2.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "jbuilder"
  spec.add_development_dependency "webmock"
end
