module Turnout
  class Configuration
    SETTINGS = [:app_root, :named_maintenance_file_paths, :default_maintenance_page, :default_reason, :default_response_code]

    SETTINGS.each do |setting|
      attr_accessor setting
    end

    def initialize
      @app_root = '.'
      @named_maintenance_file_paths = {default: app_root.join('tmp', 'maintenance.yml').to_s}
      @default_maintenance_page = Turnout::MaintenancePage::HTML
      @default_reason = "The site is temporarily down for maintenance.\nPlease check back soon."
      @default_response_code = 503
    end

    def app_root
      Pathname.new(@app_root.to_s)
    end

    def named_maintenance_file_paths=(named_paths)
      # Force keys to symbols
      @named_maintenance_file_paths = Hash[named_paths.map { |k, v| [k.to_sym, v] }]
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