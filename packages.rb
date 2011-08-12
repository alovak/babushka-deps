dep 'build-essential.managed' do
  provides []
end

dep 'bison.managed'
dep 'openssl.managed'
dep 'curl.managed'

dep 'libreadline6.managed' do
  provides []
end

dep 'libreadline6-dev.managed' do
  provides []
end

dep 'zlib1g.managed' do
  installs { via :apt, 'zlib1g','zlib1g-dev'}
  provides []
end

dep 'libssl-dev.managed' do
  provides []
end

dep 'sqlite3.managed' do
  installs { via :apt, 'libsqlite3-0', "libsqlite3-dev", "sqlite3"}
  provides []
end

dep 'libxml2-dev.managed' do
  provides []
end

dep 'libxslt1-dev.managed' do
  provides []
end

dep 'libyaml-dev.managed' do
  provides []
end

dep 'apache2-prefork.managed' do
  installs "apache2-mpm-prefork", " apache2-prefork-dev", "libapr1-dev", "libaprutil1-dev"

  provides []
end

dep 'passenger.gem' do
  installs 'passenger ~> 3.0.7'
  provides 'passenger-install-apache2-module'
end
