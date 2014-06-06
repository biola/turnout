namespace :maintenance do
  desc 'Enable the maintenance mode page ("reason", "allowed_paths" and "allowed_ips" can be passed as environment variables)'
  task :start do |t, args|
    settings = {
      'reason' => ENV['reason'],
      'allowed_paths' => split_paths(ENV['allowed_paths']),
      'allowed_ips' => split_ips(ENV['allowed_ips']),
      'response_code' => ENV['response_code']
    }

    Turnout.config.update dir: ENV['dir'] if ENV['dir'].present?

    Dir.mkdir Turnout.config.dir unless Dir.exists? Turnout.config.dir
    file = File.open settings_file, 'w'
    file.write settings.to_yaml
    file.close

    puts "Created #{settings_file}"
    puts "Run `rake maintenance:end` to stop maintenance mode"
  end

  desc 'Disable the maintenance mode page'
  task :end do
    Turnout.config.update dir: ENV['dir'] if ENV['dir'].present?

    File.delete settings_file

    puts "Deleted #{settings_file}"
  end

  def settings_file
    Rails.root.join(Turnout.config.dir, 'maintenance.yml')
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
