require 'rack'
require 'yaml'
require 'ipaddr'
require 'nokogiri'
require 'json'

class Rack::Turnout
  def initialize(app, config={})
    @app = app
    @config = config
  end

  def call(env)
    self.request = Rack::Request.new(env)
    reload_settings

    if on?
      if json?
        [ 503, { 'Content-Type' => 'application/json', 'Content-Length' => content_length(json_content) }, [json_content] ]
      else
        [ 503, { 'Content-Type' => 'text/html', 'Content-Length' => content_length(content) }, [content] ]
      end
    else
      @app.call(env)
    end
  end

  protected

  attr_accessor :request

  def json?
    return true if settings['json_response']
    false
  end

  def on?
    maintenance_file_exists? && !request_allowed?
  end

  def request_allowed?
    path_allowed? || ip_allowed?
  end

  def path_allowed?
    if settings['disallowed_paths']
      (settings['disallowed_paths']).any? do |disallowed_path|
        request.path !~ Regexp.new(disallowed_path)
      end
    else
      (settings['allowed_paths'] || []).any? do |allowed_path|
        request.path =~ Regexp.new(allowed_path)
      end
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

  def json_maintenance_page
    File.exists?(user_json_maintenance_page) ? user_json_maintenance_page : default_json_maintenance_page
  end

  def user_json_maintenance_page
    @user_json_maintenance_page ||= app_root.join('public', 'maintenance.json')
  end

  def default_json_maintenance_page
    @default_json_maintenance_page ||= File.expand_path('../../../public/maintenance.json', __FILE__)
  end

  def content_length(blob)
    blob.size.to_s
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

  def json_content
    content = JSON.parse(File.open(json_maintenance_page, 'rb').read).to_json

    reason = settings['json_reason'] || 'Down for Maintenance'
    content = content.gsub('<reason>', reason)
    
    content
  end

end
