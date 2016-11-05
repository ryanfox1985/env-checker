# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'env_checker/version'

Gem::Specification.new do |spec|
  spec.name          = 'env-checker'
  spec.version       = EnvChecker::VERSION
  spec.authors       = ['Guillermo Guerrero Ibarra']
  spec.email         = ['guillermo@guerreroibarra.com']

  spec.summary       = %q{Check your environment variables and don't forget anyone.}
  spec.description   = %q{Check your environment variables and don't forget anyone.}
  spec.homepage      = 'https://github.com/ryanfox1985/env-checker'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0'
  spec.add_development_dependency 'coveralls', '~> 0'
  spec.add_development_dependency 'simplecov', '~> 0'
end
