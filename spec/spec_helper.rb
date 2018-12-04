require 'bundler/setup'
require 'simplecov'
require 'simplecov-summary'
SimpleCov.start 'rails'
ENV["RAILS_ENV"] ||= 'test'
require 'rack/test'
require 'rspec'
require 'rspec/its'
require 'rack/turnout'
require 'fixtures/test_app'
require 'fakeredis'
# require "codeclimate-test-reporter"
formatters = [SimpleCov::Formatter::SummaryFormatter,SimpleCov::Formatter::HTMLFormatter]

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(formatters)

SimpleCov.start :rails do
  add_filter 'lib/tasks'
  add_filter ['lib/turnout/version.rb', 'lib/turnout.rb', 'lib/turnout/rake_tasks.rb', 'lib/turnout/engine.rb']
   at_exit do
     SimpleCov.result.format!
   end
 end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
