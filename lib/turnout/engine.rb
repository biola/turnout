require 'turnout'
require 'rack/turnout'
require 'rails'

# For Rails 3
if defined? Rails::Engine
  module Turnout
    class Engine < Rails::Engine
      initializer 'turnout.add_to_middleware_stack' do |app|
        app.config.middleware.use Rack::Turnout
      end
    end
  end
end