dep 'rails project' do
  requires 'user exists with password', 'user ssh key authorization', 'rvm installed', 'rvm set group for user', 'setup default ruby.rvm', 'bundler.rvm',
    'apache2 prepared', 'mysql user access', 'sendmail.managed', 'set.locale' 
  # mysql server
  # mysql databases for rails project
  # logrotate ?

  setup {
    unmeetable "This dep has to be run as root." unless shell('whoami') == 'root'
  }
end
