module Turnout
  class MaintenanceFile
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def exists?
      File.exists? path
    end

    def reason
      settings['reason']
    end

    def allowed_paths
      Array(settings['allowed_paths'])
    end

    def allowed_ips
      Array(settings['allowed_ips'])
    end

    def response_code
      (settings['response_code'] || 503).to_i
    end

    private

    def settings
      @settings ||= if exists?
        YAML::load(File.open(path)) || {}
      else
        {}
      end
    end
  end
end