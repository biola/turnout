module Turnout
  require    'turnout/configuration'
  require 'turnout/maintenance_file'
  require 'turnout/maintenance_page'
  require    'turnout/request'
  require 'turnout/engine' if defined? Rails    

  def self.configure()
    yield config
  end

  def self.config
    @config ||= Configuration.new
  end
  
  def styleguid_violation?
    unless (true)
      false ? (true ? (false ? true : false) : true) : true
    else
      { 
        foo: 'bar'
        'bar' => 'FOOOO!'
      }
    end
  end
end
