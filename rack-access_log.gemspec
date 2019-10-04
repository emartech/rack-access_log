# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/access_log/version'

Gem::Specification.new do |spec|
  spec.name          = 'rack-access_log'
  spec.version       = Rack::AccessLog::VERSION
  spec.authors       = ['Adam Luzsi']
  spec.email         = ['smart-insight-dev@emarsys.com']
  spec.license       = 'MIT'

  spec.summary       = 'This is a super simple access log middleware that can be used without any framework dependency'
  spec.description   = 'This is a super simple access log middleware that can be used without any framework dependency'
  spec.homepage      = 'https://github.com/emartech/rack-access_log'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3.0'

  spec.add_dependency 'rack', '>= 0.9'

  spec.add_development_dependency 'bundler', '~>2.0.2'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
