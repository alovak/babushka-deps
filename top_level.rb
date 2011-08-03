dep 'rails project' do
  requires 'user exists with password', 'user ssh key authorization', 'rvm installed', 'rvm set group for user', 'rvm setup default ruby',
    'apache2 prepared'
  # mysql server
  # mysql databases for rails project
  # logrotate ?

  setup {
    unmeetable "This dep has to be run as root." unless shell('whoami') == 'root'
  }
end
