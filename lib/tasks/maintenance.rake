require 'turnout'

namespace :maintenance do
  desc 'Enable the maintenance mode page ("reason", "allowed_paths", "allowed_ips" and "response_code" can be passed as environment variables)'
  rule /\Amaintenance:(.*:|)start\Z/ do |task|
    invoke_environment
    if Gem.loaded_specs.has_key? 'redis' and Turnout.config.redis_url != nil
      Turnout::RedisClient.client.set "turnout:maintenance", "default"
      puts "Created default redis key"
    else
      maint_file = maintenance_file_for(task)
      maint_file.import_env_vars(ENV)
      maint_file.write

      puts "Created #{maint_file.path}"
    end
    puts "Run `rake #{task.name.gsub(/\:start/, ':end')}` to stop maintenance mode"
  end

  desc 'Disable the maintenance mode page'
  rule /\Amaintenance:(.*:|)end\Z/ do |task|
    invoke_environment
    if Gem.loaded_specs.has_key? 'redis' and Turnout.config.redis_url != nil
      Turnout::RedisClient.client.del("turnout:maintenance")
      puts "Removed default redis key"
    else
      maint_file = maintenance_file_for(task)

      if maint_file.delete
        puts "Deleted #{maint_file.path}"
      else
        fail 'Could not find a maintenance file to delete'
      end
    end
  end

  def invoke_environment
    if Rake::Task.task_defined? 'environment'
      Rake::Task['environment'].invoke
    end
  end

  def maintenance_file_for(task)
    path_name = (task.name.split(':') - ['maintenance', 'start', 'end']).join(':')

    maint_file = if path_name == ''
      Turnout::MaintenanceConfig.default
    else
      Turnout::MaintenanceConfig.named(path_name)
    end

    fail %{Unknown path name: "#{path_name}"} if maint_file.nil?

    maint_file
  end
end
