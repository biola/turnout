lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'turnout/version'

spec = Gem::Specification.new do |s|
  s.name = 'turnout'
  s.version = Turnout::VERSION
  s.summary = "A Rack based maintenance mode plugin for Rails"
  s.description = "Turnout makes it easy to put your Rails application into maintenance mode"
  s.files = Dir['README.*', 'MIT-LICENSE', 'rails/*.rb', 'config/**/*.rb', 'lib/**/*.rb', 'lib/tasks/*.rake', 'public/*']
  s.require_path = 'lib'
  s.author = "Adam Crownoble"
  s.email = "adam.crownoble@biola.edu"
  s.homepage = "https://github.com/biola/turnout"
  s.add_dependency('nokogiri', '~>1.3')
end
