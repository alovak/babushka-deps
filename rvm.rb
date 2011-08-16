dep 'rvm installed' do
  requires 'curl.managed', 'rvm requirements'
  met? { File.exist?("/usr/local/rvm") }
  meet do
    sudo "bash < <(curl -sk https://rvm.beginrescueend.com/install/rvm)"
  end
end

dep 'rvm requirements' do
  requires %w(build-essential.managed bison.managed openssl.managed libreadline6.managed libreadline6-dev.managed curl.managed zlib1g.managed libssl-dev.managed libyaml-dev.managed sqlite3.managed libxml2-dev.managed libxslt1-dev.managed)
end

dep 'rvm set group for user' do
  before { var(:rvm_username, :default => shell("whoami")) }
  met? { shell("groups #{var(:rvm_username)}").split(" ").include?("rvm") }
  meet { sudo("adduser #{var(:rvm_username)} rvm") }
end

dep 'rvm ruby installed' do
  met? { shell("rvm list").include?(var(:default_ruby, :default => '1.9.2')) }
  meet {
    log_shell "Installing #{var(:default_ruby)} with rvm", "rvm install #{var(:default_ruby)}"
  }
end

dep 'rvm setup default ruby' do
  requires 'rvm ruby installed'
  met? { shell("rvm list").include?("=>") }
  meet {
    log_shell "Installing #{var(:default_ruby)} with rvm", "rvm use #{var(:default_ruby)} --default"
  }
end

dep 'rvm passenger module installed' do
  setup { set( :passenger_path, Babushka::GemHelper.gem_path_for("passenger")) }
  met? { File.exists?("#{var(:passenger_path)}/ext/apache2/mod_passenger.so") }
  meet { shell("passenger-install-apache2-module -a") }
end

dep 'rvm passenger apache configured' do
  requires 'rvm passenger module installed'

  met? { File.exist?("/etc/apache2/mods-enabled/passenger.conf") }
  meet {
    ruby_bin_path = shell("gem env | grep 'RUBY EXECUTABLE' -")
    matches = ruby_bin_path.match(/[^\/]*(.*rvm\/)rubies\/([^\/]*)/)
    ruby_wrapper_path = "#{matches[1]}wrappers/#{matches[2]}/ruby"
    
    str = [
      "LoadModule passenger_module #{var(:passenger_path)}/ext/apache2/mod_passenger.so",
      "PassengerRoot #{var(:passenger_path)}",
      "PassengerRuby #{ ruby_wrapper_path }",
      "PassengerMaxPoolSize 2",
      "PassengerPoolIdleTime 0",
      "PassengerUseGlobalQueue on"
    ]
    append_to_file str.join("\n "), "/etc/apache2/mods-enabled/passenger.conf"
  }
end
