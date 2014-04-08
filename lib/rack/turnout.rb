require 'rack'
require 'yaml'
require 'ipaddr'
require 'nokogiri'

class Rack::Turnout
  def initialize(app, config={})
    @app = app
    @config = config
  end

  def call(env)
    self.request = Rack::Request.new(env)
    reload_settings

    if on?
      [ response_code, { 'Content-Type' => 'text/html', 'Content-Length' => content_length }, [content] ]
    else
      @app.call(env)
    end
  end

  protected

  attr_accessor :request

  def on?
    maintenance_file_exists? && !request_allowed?
  end

  def request_allowed?
    path_allowed? || ip_allowed?
  end

  def path_allowed?
    (settings['allowed_paths'] || []).any? do |allowed_path|
      request.path =~ Regexp.new(allowed_path)
    end
  end

  def ip_allowed?
    begin
      ip = IPAddr.new(request.ip.to_s)
    rescue ArgumentError
      return false
    end

    (settings['allowed_ips'] || []).any? do |allowed_ip|
      IPAddr.new(allowed_ip).include? ip
    end
  end

  def reload_settings
    @settings = nil
    settings
  end

  def settings
    @settings ||= if File.exists? settings_file
      YAML::load(File.open(settings_file)) || {}
    else
      {}
    end
  end

  def app_root
    @app_root ||= Pathname.new(
      @config[:app_root] || @app.respond_to?(:root)? @app.root.to_s : '.'
    )
  end

  def settings_file
    app_root.join('tmp', 'maintenance.yml')
  end

  def maintenance_file_exists?
    File.exists? settings_file
  end

  def maintenance_page
    File.exists?(app_maintenance_page) ? app_maintenance_page : default_maintenance_page
  end

  def app_maintenance_page
    @app_maintenance_page ||= app_root.join('public', 'maintenance.html')
  end

  def default_maintenance_page
    @default_maintenance_page ||= File.expand_path('../../../public/maintenance.html', __FILE__)
  end

  def content_length
    content.size.to_s
  end

  def content
    content = File.open(maintenance_page, 'rb').read

    if settings['reason']
      html = Nokogiri::HTML(content)
      html.at_css('#reason').inner_html = Nokogiri::HTML.fragment(settings['reason'])
      content = html.to_s
    end

    content
  end

  def response_code
    settings['response_code'] || 503
  end
end
