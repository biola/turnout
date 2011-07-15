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
      [ 503, { 'Content-Type' => 'text/html', 'Content-Length' => content_length }, [content] ]
    else
      @app.call(env)
    end
  end

  protected
  
  def on?(env)
    request = Rack::Request.new(env)
    
    return false if ip_allowed?(request.ip)
    File.exists? settings_file
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
      html.at_css('#reason').inner_html = settings['reason']
      content = html.to_s
    end
    
    content
  end

end
