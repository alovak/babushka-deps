dep 'sshd.managed' do
  installs {
    via :apt, 'openssh-server'
  }
end
