require 'yaml'
require 'fileutils'

module Turnout
  class MaintenanceFile
    attr_reader :path

    SETTINGS = [:reason, :allowed_paths, :allowed_ips, :response_code]
    attr_reader *SETTINGS

    def initialize(path)
      @path = path
      @reason = Turnout.config.default_reason
      @allowed_paths = []
      @allowed_ips = []
      @response_code = Turnout.config.default_response_code

      import_yaml if exists?
    end

    def exists?
      File.exists? path
    end

    def to_h
      SETTINGS.each_with_object({}) do |att, hash|
        hash[att] = send(att)
      end
    end

    def to_yaml(key_mapper = :to_s)
      to_h.each_with_object({}) { |(key, val), hash|
        hash[key.send(key_mapper)] = val
      }.to_yaml
    end

    def write
      FileUtils.mkdir_p(dir_path) unless Dir.exists? dir_path

      File.open(path, 'w') do |file|
        file.write to_yaml
      end
    end

    def delete
      File.delete(path) if exists?
    end

    def import_env_vars(env_vars)
      SETTINGS.map(&:to_s).each do |var|
        self.send(:"#{var}=", env_vars[var]) unless env_vars[var].nil?
      end

      true
    end

    private

    def reason=(reason)
      @reason = reason.to_s
    end

    # Splits strings on commas for easier importing of environment variables
    def allowed_paths=(paths)
      if paths.is_a? String
        # Grab everything between commas that aren't escaped with a backslash
        paths = paths.to_s.split(/(?<!\\),\ ?/).map do |path|
          path.strip.gsub('\,', ',') # remove the escape characters
        end
      end

      @allowed_paths = paths
    end

    # Splits strings on commas for easier importing of environment variables
    def allowed_ips=(ips)
      ips = ips.to_s.split(',') if ips.is_a? String

      @allowed_ips = ips
    end

    def response_code=(code)
      @response_code = code.to_i
    end

    def dir_path
      File.dirname(path)
    end

    def import_yaml
      yaml = YAML::load(File.open(path)) || {}

      SETTINGS.map(&:to_s).each do |att|
        self.send(:"#{att}=", yaml[att]) unless yaml[att].nil?
      end

      true
    end
  end
end