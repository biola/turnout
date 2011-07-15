namespace :maintenance do

  desc 'Enable the maintenance mode page ("reason" and/or "allowed_ips" can be passed as environment variables)'
  task :start do |t, args|
    settings = { 'reason' => ENV['reason'], 'allowed_ips' => ENV['allowed_ips'].to_s.split(',') }
     
    file = File.open settings_file, 'w'
    file.write settings.to_yaml
    file.close
  end

  desc 'Disable the maintenance mode page'
  task :end do 
    File.delete settings_file
  end
  
  def settings_file
    Rails.root.join('tmp', 'maintenance.yml')
  end

end
