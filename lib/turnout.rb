module Turnout
  require 'turnout/configuration'
  require 'turnout/maintenance_file'
  require 'turnout/maintenance_page'
  require 'turnout/request'
  require 'turnout/engine' if defined? Rails

  def self.configure
    yield config
  end

  def self.config
    @config ||= Configuration.new
  end
end
