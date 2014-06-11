require 'rack'
require 'yaml'
require 'ipaddr'
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
    self.request = Rack::Request.new(env)
    reload! # TODO: check maintenance.yml file time first

    if on?
      page_class = Turnout::MaintenancePage.best_for(env)
      page = page_class.new(settings.reason)

      page.rack_response(settings.response_code)
    else
      @app.call(env)
    end
  end

  protected

  attr_accessor :request

  def maintenance_file
    @maintenance_file ||= (
      file = Turnout.config.app_root.join(Turnout.config.dir, 'maintenance.yml')
      Turnout::MaintenanceFile.new file
    )
  end
  alias :settings :maintenance_file

  def reload!
    # Clear memoization
    @maintenance_file = nil
    @maintenance_page = nil
  end

  def on?
    maintenance_file.exists? && !request_allowed?
  end

  def request_allowed?
    path_allowed? || ip_allowed?
  end

  def path_allowed?
    settings.allowed_paths.any? do |allowed_path|
      request.path =~ Regexp.new(allowed_path)
    end
  end

  def ip_allowed?
    begin
      ip = IPAddr.new(request.ip.to_s)
    rescue ArgumentError
      return false
    end

    settings.allowed_ips.any? do |allowed_ip|
      IPAddr.new(allowed_ip).include? ip
    end
  end
end
