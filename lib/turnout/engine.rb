require 'turnout'
require 'rails'
require 'active_record'
require 'rack/turnout'

module Turnout
  class Engine < Rails::Engine
    initializer 'turnout.add_to_middleware_stack' do |app|
      app.config.middleware.use Rack::Turnout
    end
  end
end
