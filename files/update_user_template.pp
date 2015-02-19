user { "$user":
  home => "/home/$user",
  shell => "/bin/bash",
  managehome => "true",
  groups => ["$group"],
} ->
ssh_authorized_key { "$user":
  user => "$user",
  ensure => present, 
  type => "ssh-rsa", 
  key => "$ssh_key", 
} 
