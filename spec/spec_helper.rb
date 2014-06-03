require 'bundler/setup'
require 'rack/test'
require 'rspec'
require 'rack/turnout'
require 'fixtures/test_app'
require 'json'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
