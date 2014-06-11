module Turnout
  class Configuration
    SETTINGS = [:app_root, :dir, :default_maintenance_page, :default_reason, :default_response_code]

    SETTINGS.each do |setting|
      attr_accessor setting
    end

    def initialize
      @app_root = '.'
      @dir = 'tmp'
      @default_maintenance_page = Turnout::MaintenancePage::HTML
      @default_reason = "The site is temporarily down for maintenance.\nPlease check back soon."
      @default_response_code = 503
    end

    def app_root
      Pathname.new(@app_root.to_s)
    end

    def update(settings_hash)
      settings_hash.each do |setting, value|
        unless SETTINGS.include? setting.to_sym
          raise ArgumentError, "invalid setting: #{setting}"
        end

        self.public_send "#{setting}=", value
      end
    end
  end
end