require 'turnout'
require 'rack/turnout'
require 'rails' unless defined? Rails

# For Rails 3
if defined? Rails::Engine

  require 'active_record'

  module Turnout
    class Engine < Rails::Engine
      initializer 'turnout.add_to_middleware_stack' do |app|
        app.config.middleware.use Rack::Turnout
      end
    end
  end

end
