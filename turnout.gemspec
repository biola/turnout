lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'turnout/version'

spec = Gem::Specification.new do |s|
  s.name = 'turnout'
  s.version = Turnout::VERSION
  s.summary = 'A Rack based maintenance mode plugin for Rails'
  s.description = 'Turnout makes it easy to put your Rails application into maintenance mode'
  s.files = Dir['README.*', 'MIT-LICENSE', 'rails/*.rb', 'config/**/*.rb', 'lib/**/*.rb', 'lib/tasks/*.rake', 'public/*']
  s.require_path = 'lib'
  s.author = 'Adam Crownoble'
  s.email = 'adam@obledesign.com'
  s.homepage = 'https://github.com/biola/turnout'
  s.license = 'MIT'
  s.add_dependency('rack', '~> 1.3')
  s.add_dependency('rack-accept', '~> 0.4')
  s.add_development_dependency('rack-test', '~> 0.6')
  s.add_development_dependency('rspec', '~> 3.0')
  s.add_development_dependency('rspec-its', '~> 1.0')
end
