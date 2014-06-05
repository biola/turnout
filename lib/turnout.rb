module Turnout
  require 'turnout/configuration'
  require 'turnout/engine' if defined? Rails

  def self.configure
    yield config
  end

  def self.config
    @config ||= Configuration.new
  end
end
