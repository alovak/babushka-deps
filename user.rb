dep 'user setup' do
  requires 'admins can sudo', 'sshd.managed', 'user exists with password', 'user ssh key authorization'
end

dep 'user ssh key authorization' do
  def ssh_dir
    "~#{var(:username)}" / '.ssh'
  end
  def group
    shell "id -gn #{var(:username)}"
  end
  met? {
    sudo "grep '#{var(:your_ssh_public_key)}' '#{ssh_dir / 'authorized_keys'}'"
  }
  before {
    sudo "mkdir -p '#{ssh_dir}'"
    sudo "chmod 700 '#{ssh_dir}'"
  }
  meet {
    append_to_file var(:your_ssh_public_key), (ssh_dir / 'authorized_keys'), :sudo => true
  }
  after {
    sudo "chown -R #{var(:username)}:#{group} '#{ssh_dir}'"
    sudo "chmod 600 #{(ssh_dir / 'authorized_keys')}"
  }
end

dep 'user exists with password' do
  requires 'user exists'
  met? { shell('sudo cat /etc/shadow')[/^#{var(:username)}:[^\*!]/] }
  meet { sudo "echo -e '#{var(:password)}\n#{var(:password)}' | passwd #{var(:username)}" }
end

dep 'user exists' do
  setup {
    define_var :home_dir_base, :default => L{
      var(:username)['.'] ? '/srv/http' : '/home'
    }
  }

  met? { grep(/^#{var(:username)}:/, '/etc/passwd') }
  meet {
    sudo "mkdir -p #{var :home_dir_base}" and
    sudo "useradd -m -s /bin/bash -b #{var :home_dir_base} -G admin #{var(:username)}" and
    sudo "chmod 701 #{var(:home_dir_base) / var(:username)}"
  }
end

dep 'admins can sudo' do
  requires 'admin group'
  met? { !sudo('cat /etc/sudoers').split("\n").grep(/^%admin/).empty? }
  meet { append_to_file '%admin ALL=(ALL) ALL', '/etc/sudoers', :sudo => true }
end

dep 'admin group' do
  met? { grep /^admin\:/, '/etc/group' }
  meet { sudo 'groupadd admin' }
end
