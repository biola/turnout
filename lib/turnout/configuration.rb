require_relative './ordered_options'
module Turnout
  class Configuration
    SETTINGS = [
      :app_root,
      :named_maintenance_file_paths,
      :maintenance_pages_path,
      :default_maintenance_page,
      :default_reason,
      :default_allowed_ips,
      :skip_middleware,
      :default_allowed_paths,
      :default_response_code,
      :default_retry_after,
      :i18n
    ].freeze

    SETTINGS.each do |setting|
      attr_accessor setting
    end

    def initialize
      @skip_middleware = false
      @app_root = '.'
      @named_maintenance_file_paths = {default: app_root.join('tmp', 'maintenance.yml').to_s}
      @maintenance_pages_path = app_root.join('public').to_s
      @default_maintenance_page = Turnout::MaintenancePage::HTML
      @default_reason = "The site is temporarily down for maintenance.\nPlease check back soon."
      @default_allowed_paths = []
      @default_allowed_ips = []
      @default_response_code = 503
      @default_retry_after = 7200 # 2 hours by default
      @i18n = Turnout::OrderedOptions.new
      @i18n.railties_load_path = []
      @i18n.load_path = []
      @i18n.fallbacks = Turnout::OrderedOptions.new
      @i18n.enabled = false
      @i18n.use_language_header = false
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
