dep 'apache2 prepared' do
  requires 'apache2-prefork.managed', 'passenger.gem', 'rvm passenger module installed', 'apache2 vhost configured'
  after { "/etc/init.d/apache2 reload" }
end

dep 'apache2 vhost configured' do
  met? { File.exist?("/etc/apache2/sites-enabled/#{var(:domain)}") }

  meet {
    render_erb "apache2/vhost.conf.erb", :to => "/etc/apache2/sites-enabled/#{var(:domain)}"
  }

  after { 
    shell "rm /etc/apache2/sites-enabled/000-default"
  }
end
