require 'bundler/setup'
require 'rspec'
require 'turnout'
require 'fixtures/test_app'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end