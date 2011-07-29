# For Rails 2.3
unless defined? Rails::Engine
  config.middleware.use 'Rack::Turnout'
end
