dep 'mysql user access' do
  requires 'mysql create db'
  define_var :db_user, :default => :username
  define_var :db_host, :default => 'localhost'
  met? { raw_shell("echo 'quit' | mysql -u #{var :db_user} --password=#{var :db_pass} #{var :db_name}").ok?  }
  meet { mysql %Q{GRANT ALL PRIVILEGES ON #{var :db_name}.* TO '#{var :db_user}'@'#{var :db_host}' IDENTIFIED BY '#{var :db_pass}'} }
end

dep 'mysql create db' do
  requires 'mysql configured'
  met? { mysql("SHOW DATABASES").split("\n")[1..-1].any? {|l| /\b#{var :db_name}\b/ =~ l } }
  meet { mysql "CREATE DATABASE #{var :db_name}" }
end

dep 'mysql configured' do
  requires 'mysql root password'
end

dep 'mysql root password' do
  requires 'mysql.managed'
  define_var :db_password, :message => 'msql root password'
  met? { raw_shell("echo '\q' | mysql -u root").stderr["Access denied for user 'root'@'localhost' (using password: NO)"] }
  meet { mysql(%Q{GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '#{var :db_password}'}, 'root', false) }
end

dep 'mysql.managed' do
  installs %w[mysql-server libmysqlclient16-dev]
  provides 'mysql'
end

