require 'rack'
require 'yaml'
require 'turnout'

class Rack::Turnout
  def initialize(app, config={})
    @app = app

    Turnout.config.update config

    if config[:app_root].nil? && app.respond_to?(:app_root)
      Turnout.config.app_root = app.app_root
    end
  end

  def call(env)
    request = Turnout::Request.new(env)
    settings = maintenance_file

    if settings.exists? && !request.allowed?(settings)
      page_class = Turnout::MaintenancePage.best_for(env)
      page = page_class.new(settings.reason)

      page.rack_response(settings.response_code)
    else
      @app.call(env)
    end
  end

  protected

  def maintenance_file
    file = Turnout.config.app_root.join(Turnout.config.dir, 'maintenance.yml')
    Turnout::MaintenanceFile.new file
  end
end
