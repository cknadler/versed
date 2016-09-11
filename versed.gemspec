# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "versed/version"

Gem::Specification.new do |s|
  s.name        = "versed"
  s.version     = Versed::VERSION
  s.authors     = ["Chris Knadler"]
  s.email       = "takeshi91k@gmail.com"
  s.homepage    = "https://github.com/cknadler/versed"
  s.summary     = "Visualize routine adherence and track progress"
  s.description = "Versed helps you visualize your progress against your scheduled weekly routine."
  s.license     = "MIT"

  s.required_ruby_version = ">= 2.0.0"

  s.add_runtime_dependency "mustache", "~> 1.0"
  s.add_runtime_dependency "pdfkit", "~> 0.8.2"

  s.add_development_dependency "rake", "~> 10.5"
  s.add_development_dependency "minitest", "~> 5.8"

  s.bindir           = "bin"
  s.require_paths    = ["lib"]
  s.executables      = ["versed"]
  s.files            = Dir["lib/**/*", "templates/**/*"]
  s.test_files       = Dir["test/**/test*"]
  s.extra_rdoc_files = ["README.md","LICENSE"]
end
