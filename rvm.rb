meta :rvm do
  def rvm args
    shell "/usr/local/rvm/bin/rvm #{args}", :log => args['install']
  end

  def gem_path(gem_name)
    env_info.val_for('INSTALLATION DIRECTORY') + "/gems/" + gem_name + "-" + version(gem_name)
  end

  def ruby_wrapper_path
    matches = env_info.val_for('RUBY EXECUTABLE').match(/[^\/]*(.*rvm\/)rubies\/([^\/]*)/)
    "#{matches[1]}wrappers/#{matches[2]}/ruby"
  end

  private

  def env_info
    @_cached_env_info ||= rvm('gem env')
  end

  def version(gem_name)
    spec = YAML.parse(rvm("gem specification #{gem_name}"))
    spec.select("/version/version")[0].value
  end
end

dep 'test.rvm' do
  met? { false }
  meet do
    # puts gem_path('passenger')
    # puts ruby_wrapper_path
    yaml = rvm('gem specification passenger')
    gem_spec = Gem::Specification.from_yaml(yaml)
    puts gem_spec.inspect
  end
end

dep 'rvm installed' do
  requires 'curl.managed', 'rvm requirements'
  met? { File.exist?("/usr/local/rvm") }
  meet do
    log_shell "Installing rvm",
              %{bash -c "`curl -sk https://rvm.beginrescueend.com/install/rvm`"}
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

dep 'ruby installed.rvm' do
  met? { rvm("list").include?(var(:default_ruby, :default => '1.9.2')) }

  meet {
    File.open("/root/.curlrc", "w") {|f| f.puts "-k"}
    rvm("install #{var(:default_ruby)}")
    shell "rm /root/.curlrc"
  }
end

dep 'setup default ruby.rvm' do
  requires 'ruby installed.rvm'
  met? { login_shell('ruby --version')["ruby #{var(:default_ruby)}"] }
  meet {
    rvm("use #{var(:default_ruby)} --default")
  }
end

dep 'bundler.rvm' do
  met? { rvm("gem list bundler")["bundler"] }
  meet { rvm("gem install bundler --no-rdoc --no-ri") }
end

dep 'passenger.rvm' do
  met? { rvm("gem list passenger")["passenger"] }
  meet { rvm("gem install passenger --no-rdoc --no-ri") }
end

dep 'passenger module installed.rvm' do
  requires 'libcurl4-openssl-dev.managed'
  setup { set( :passenger_path, gem_path("passenger")) }
  met? { File.exists?("#{var(:passenger_path)}/ext/apache2/mod_passenger.so") }
  meet { login_shell("passenger-install-apache2-module -a") }
end

dep 'passenger apache configured.rvm' do
  requires 'passenger module installed.rvm'

  met? { File.exist?("/etc/apache2/mods-enabled/passenger.conf") }
  meet {
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
