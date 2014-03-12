namespace :maintenance do
  desc 'Enable the maintenance mode page ("reason", "allowed_paths" and "allowed_ips" can be passed as environment variables)'
  task :start do |t, args|
    settings = {
      'reason' => ENV['reason'],
      'allowed_paths' => split_paths(ENV['allowed_paths']),
      'allowed_ips' => split_ips(ENV['allowed_ips']),
      'disallowed_paths' => split_paths(ENV['disallowed_paths'])
    }

    file = File.open settings_file, 'w'
    file.write settings.to_yaml
    file.close

    puts "Created #{settings_file}"
    puts "Run `rake maintenance:end` to stop maintenance mode"
  end

  desc 'Enable the maintenance mode with JSON return ("reason", "allowed_paths" and "allowed_ips" can be passed as environment variables) reason should be valid JSON'
  task :start_json do |t, args|
    settings = {
      'json_reason' => ENV['reason'],
      'allowed_paths' => split_paths(ENV['allowed_paths']),
      'allowed_ips' => split_ips(ENV['allowed_ips']),
      'json_response' => true,
      'disallowed_paths' => split_paths(ENV['disallowed_paths'])
    }

    file = File.open settings_file, 'w'
    file.write settings.to_yaml
    file.close
    puts "Created #{settings_file}"
    puts "Run `rake maintenance:end` to stop json maintenance mode"
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
    # I had this for 1.9.2 but no lookbehinds in 1.8.7 :(
    #paths = paths_string.to_s.split(/(?<!\\),\ ?/)

    # Grab everything between commas that aren't escaped with a backslash
    paths = paths_string.to_s.scan(/(?:\\,|[^,])+/)
    paths.map! do |path|
      path.strip.gsub('\,', ',') # remove the escape characters
    end
    paths
  end

  def split_ips(ips_string)
    ips_string.to_s.split(',')
  end
end
