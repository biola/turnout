require 'turnout'

namespace :maintenance do
  desc 'Enable the maintenance mode page ("reason", "allowed_paths" and "allowed_ips" can be passed as environment variables)'
  task :start do
    maint_file = Turnout::MaintenanceFile.find
    maint_file.import_env_vars(ENV)
    maint_file.write

    puts "Created #{maint_file.path}"
    puts "Run `rake maintenance:end` to stop maintenance mode"
  end

  desc 'Disable the maintenance mode page'
  task :end do
    maint_file = Turnout::MaintenanceFile.find
    maint_file.delete

    puts "Deleted #{maint_file.path}"
  end
end
