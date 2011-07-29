# This is an include file for Rakefiles in Rails 2.3
# since rake tasks aren't included automatically in Rails 2.3 engines
Dir["#{Gem.searcher.find('turnout').full_gem_path}/lib/tasks/*.rake"].each { |ext| load ext }
