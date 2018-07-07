$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'jirify/version'

Gem::Specification.new do |s|
  s.name        = 'jirify'
  s.version     = Jirify::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Georgi Gardev']
  s.email       = 'georgi@gardev.com'
  s.homepage    = 'https://github.com/GeorgeSG/jirify'
  s.summary     = 'JIRA CLI'
  s.description = 'JIRA for your terminal'
  s.license     = 'MIT'

  s.files       = Dir.glob('{bin,lib}/**/*') + %w[README.md]
  s.executables = ['jira']
  s.require_paths = ['lib']

  s.add_dependency 'colorize', '~> 0.8'
  s.add_dependency 'jira-ruby', '~> 1.5'
  s.add_dependency 'terminal-table', '~> 1.8'
  s.add_dependency 'thor', '~> 0.20'
  s.add_dependency 'launchy', '~> 2.4'
end
