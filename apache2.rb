dep 'apache2 prepared' do
  requires 'apache2-prefork.managed', 'passenger.gem', 'rvm passenger apache configured', 'apache2 vhost configured'
  after { "apache2ctl restart" }
end

dep 'apache2 vhost configured' do
  met? { File.exist?("/etc/apache2/sites-enabled/#{var(:domain)}") }

  meet {
    render_erb "apache2/vhost.conf.erb", :to => "/etc/apache2/sites-enabled/#{var(:domain)}"
    project_dir = "/var/www/#{var(:domain)}"
    shell "mkdir #{project_dir}"
    shell "chown -R #{var(:deploy_user)}:#{var(:deploy_user)} #{project_dir}"
  }

  after { 
    shell "rm /etc/apache2/sites-enabled/000-default"
  }
end
