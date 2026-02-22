# frozen_string_literal: true

require_relative 'lib/bardo/version'

Gem::Specification.new do |spec|
  spec.name = 'bardo'
  spec.version = Bardo::VERSION
  spec.authors = ['Matheus Barbosa']
  spec.summary = 'CLI para músicos que querem dominar teoria musical e improvisação'
  spec.description = 'Ferramenta de terminal para aprender teoria musical, escalas, campo harmônico e improvisação de forma prática e interativa.'
  spec.homepage = 'https://github.com/matheusbarbosa/bardo'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0'

  spec.files = Dir['lib/**/*', 'bin/*', 'LICENSE', 'README.md']
  spec.bindir = 'bin'
  spec.executables = %w[bardo bardo-cli]

  spec.add_dependency 'pastel', '~> 0.8'
  spec.add_dependency 'thor', '~> 1.3'
  spec.add_dependency 'tty-prompt', '~> 0.23'
  spec.add_dependency 'tty-table', '~> 0.12'

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.13'
end
