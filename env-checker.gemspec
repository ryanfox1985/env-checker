# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'env_checker/version'

Gem::Specification.new do |spec|
  spec.name          = 'env-checker'
  spec.version       = EnvChecker::VERSION
  spec.authors       = ['Guillermo Guerrero Ibarra']
  spec.email         = ['guillermo@guerreroibarra.com']

  spec.summary       = <<-EOF
    Don't forget your environment variables when your app changes the
    environment.
  EOF

  spec.description   = <<-EOF
    When you are developing a new feature if your app have some environments
    like test, staging and production is easy to forget an environment variable
    in the middle of the process. Also when you migrate the app to another
    server is easy to forget an environment variable.
  EOF

  spec.homepage      = 'https://github.com/ryanfox1985/env-checker'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.0.0'

  spec.add_runtime_dependency 'thor', '~> 0.19.1'
  spec.add_runtime_dependency 'slack-notifier', '~> 1.5.1'
  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 11.3'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'rubocop', '~> 0.45'
  spec.add_development_dependency 'coveralls', '~> 0.8'
  spec.add_development_dependency 'simplecov', '~> 0.12'
  spec.add_development_dependency 'byebug', '~> 9.0'
end
