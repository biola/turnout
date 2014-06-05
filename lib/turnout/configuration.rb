module Turnout
  class Configuration
    SETTINGS = [:app_root]

    SETTINGS.each do |setting|
      attr_accessor setting
    end

    def initialize
      @app_root = '.'
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