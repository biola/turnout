require 'ipaddr'

module Turnout
  class Request
    def initialize(env)
      @rack_request = Rack::Request.new(env)
    end

    def allowed?(settings)
      path_allowed?(settings.allowed_paths) || ip_allowed?(settings.allowed_ips)
    end

    private

    attr_reader :rack_request

    def path_allowed?(allowed_paths)
      allowed_paths.any? do |allowed_path|
        rack_request.path =~ Regexp.new(allowed_path)
      end
    end

    def ip_allowed?(allowed_ips)
      begin
        ip = IPAddr.new(rack_request.ip.to_s)
      rescue ArgumentError
        return false
      end

      allowed_ips.any? do |allowed_ip|
        IPAddr.new(allowed_ip).include? ip
      end
    end
  end
end
