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
    reload_settings

    if on?(env)
      if json?(env)
        [ 200, { 'Content-Type' => 'application/json', 'Content-Length' => content_length(json_content) }, [json_content] ]
      else
        [ 503, { 'Content-Type' => 'text/html', 'Content-Length' => content_length(content) }, [content] ]
      end
    else
      @app.call(env)
    end
  end

  protected

  def json?(env)
    request = Rack::Request.new(env)
    return true if settings['json_for_all_requests']
debugger
    return true if request
    false
  end

  def on?(env)
    request = Rack::Request.new(env)

    return false if path_allowed?(request.path)
    return false if ip_allowed?(request.ip)
    maintenance_file_exists?
  end

  def path_allowed?(path)
    (settings['allowed_paths'] || []).each do |allowed_path|
      return true if path =~ Regexp.new(allowed_path)
    end
    false
  end

  def ip_allowed?(ip)
    ip = IPAddr.new(ip) unless ip.is_a? IPAddr
    (settings['allowed_ips'] || []).each do |allowed_ip|
      return true if IPAddr.new(allowed_ip).include? ip
    end
    false
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
    File.exists?(json_user_maintenance_page) ? user_json_maintenance_page : default_json_maintenance_page
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
    if settings['json_return']
      content = setting['json_return']
    else
      content = File.open(json_maintenance_page, 'rb').read
    end

    content
  end

end
