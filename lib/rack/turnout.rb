require 'rack'
require 'yaml'
require 'ipaddr'
require 'nokogiri'
require 'turnout'

class Rack::Turnout
  def initialize(app, settings={})
    @app = app

    Turnout.config.update settings

    if settings[:app_root].nil? && app.respond_to?(:app_root)
      Turnout.config.app_root = app.app_root
    end
  end

  def call(env)
    self.request = Rack::Request.new(env)
    reload_settings

    if on?
      [ response_code, { 'Content-Type' => content_type, 'Content-Length' => content_length }, [content] ]
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

  def settings_file
    Turnout.config.app_root.join(Turnout.config.dir, 'maintenance.yml')
  end

  def maintenance_file_exists?
    File.exists? settings_file
  end

  def maintenance_page
    File.exists?(app_maintenance_page) ? app_maintenance_page : default_maintenance_page
  end

  def maintenance_page_json
    File.exists?(app_maintenance_page_json) ? app_maintenance_page_json : default_maintenance_page_json
  end

  def app_maintenance_page
    @app_maintenance_page ||= Turnout.config.app_root.join('public', 'maintenance.html')
  end

  def app_maintenance_page_json
    @app_maintenance_page_json ||= Turnout.config.app_root.join('public', 'maintenance.json')
  end

  def default_maintenance_page
    @default_maintenance_page ||= File.expand_path('../../../public/maintenance.html', __FILE__)
  end

  def default_maintenance_page_json
    @default_maintenance_page_json ||= File.expand_path('../../../public/maintenance.json', __FILE__)
  end

  def content_length
    content.size.to_s
  end

  def content
    switch_type prepare_json_response, prepare_html_response
  end

  def prepare_json_response
    content = File.open(maintenance_page_json, 'rb').read

    if settings['reason']
      json = JSON.parse content
      json['reason'] = settings['reason']
      content = json.to_json
    end

    content
  end

  def prepare_html_response
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

  def json?
    accept = self.request.env['HTTP_ACCEPT']
    accept != nil && accept.include?('json')
  end

  def content_type
    switch_type 'application/json', 'text/html'
  end

  def switch_type json_result, html_result
    if json?
      json_result
    else
      html_result
    end
  end
end
