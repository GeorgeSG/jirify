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
  s.metadata    = { 'source_code_uri' => 'https://github.com/GeorgeSG/jirify' }
  s.post_install_message = 'Thanks for installing! Run <jira setup> for initial configuration.'

  s.files         = Dir.glob('{bin,lib}/**/*') + %w[README.md jirify.bash_completion.sh]
  s.executables   = ['jira']
  s.require_paths = ['lib']

  s.add_runtime_dependency 'colorize', '~> 0.8', '>= 0.8.1'
  s.add_runtime_dependency 'jira-ruby', '~> 1.5'
  s.add_runtime_dependency 'launchy', '~> 2.4', '>= 2.4.3'
  s.add_runtime_dependency 'terminal-table', '~> 1.8'
  s.add_runtime_dependency 'thor', '~> 0.20'

  s.add_development_dependency 'coveralls', '~> 0.7', '>= 0.7.1'
  s.add_development_dependency 'guard', '~> 2.14', '>= 2.14.2'
  s.add_development_dependency 'guard-rspec', '~> 4.7', '>= 4.7.3'
  s.add_development_dependency 'rake', '~> 12.1'
  s.add_development_dependency 'rake-release', '~> 1.0', '>= 1.0.1'
  s.add_development_dependency 'rspec', '~> 3.7'
  s.add_development_dependency 'rubocop', '~> 0.57', '>= 0.57.2'
  s.add_development_dependency 'rubocop-rspec', '~> 1.27'
  s.add_development_dependency 'simplecov', '~> 0.10', '>= 0.10.2'
end
