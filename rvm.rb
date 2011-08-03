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
