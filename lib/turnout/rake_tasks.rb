# This file is meant to be used to include rake tasks in a Rakefile by adding
# require 'turnout/rake_tasks'
Dir[File.expand_path('../../tasks/*.rake', __FILE__)].each { |ext| import ext }
