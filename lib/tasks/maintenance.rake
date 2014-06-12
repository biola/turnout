require 'turnout'

namespace :maintenance do
  desc 'Enable the maintenance mode page ("reason", "allowed_paths" and "allowed_ips" can be passed as environment variables)'
  task :start do
    maintenance_file.import_env_vars(ENV)
    maintenance_file.write

    puts "Created #{maintenance_file.path}"
    puts "Run `rake maintenance:end` to stop maintenance mode"
  end

  desc 'Disable the maintenance mode page'
  task :end do
    maintenance_file.delete

    puts "Deleted #{maintenance_file.path}"
  end

  private

  def maintenance_file
    @maintenance_file ||= (
      path = Turnout.config.app_root.join(Turnout.config.dir, 'maintenance.yml')
      Turnout::MaintenanceFile.new(path)
    )
  end
end
