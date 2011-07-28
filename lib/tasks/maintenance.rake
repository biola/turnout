namespace :maintenance do

  desc 'Enable the maintenance mode page ("reason" and/or "allowed_ips" can be passed as environment variables)'
  task :start do |t, args|
    settings = {
      'reason' => ENV['reason'],
      'allowed_paths' => split_paths(ENV['allowed_paths']),
      'allowed_ips' => split_ips(ENV['allowed_ips'])
    }
     
    file = File.open settings_file, 'w'
    file.write settings.to_yaml
    file.close
    
    puts "Created #{settings_file}"
    puts "Run `rake maintenance:end` to stop maintenance mode"
  end

  desc 'Disable the maintenance mode page'
  task :end do 
    File.delete settings_file
    
    puts "Deleted #{settings_file}"
  end
  
  def settings_file
    Rails.root.join('tmp', 'maintenance.yml')
  end

  def split_paths(paths_string)
    # used negative lookbehind to split on "," but not on "\,"
    paths = paths_string.to_s.split(/(?<!\\),\ ?/)
    paths.map! do |path|
      path.gsub('\,', ',') # remove the escape characters
    end
    paths
  end

  def split_ips(ips_string)
    ips_string.to_s.split(',')
  end

end
