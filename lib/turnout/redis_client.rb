begin
  require 'redis'
rescue LoadError
end

module Turnout
  class RedisClient
    @@client = nil

    def self.client
      return @@client if @@client
      if Gem.loaded_specs.has_key?('redis') && Turnout.config.redis_url != nil
        @@client = Redis.new(url: Turnout.config.redis_url)
      end
    end

    def self.maintenance?(settings)
      return false unless self.client
      message = self.client.get("turnout:maintenance")
      if (message.is_a? String) && (message != "default")
        settings.change_reason(message)
      end
      message != nil
    rescue
      false
    end
  end
end
