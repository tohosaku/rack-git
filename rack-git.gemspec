# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rack/git/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["tohosaku"]
  gem.email         = ["ny@cosmichorror.org"]
  gem.description   = %q{rack application (not a middleware) serves contents in a git repository directly }
  gem.summary       = %q{rack application (not a middleware) serves contents in a git repository directly } 
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rack-git"
  gem.require_paths = ["lib"]
  gem.version       = Rack::Git::VERSION
  gem.add_dependency('grit')
end
