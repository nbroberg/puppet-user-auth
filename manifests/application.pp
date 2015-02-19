class user-auth::application (
  $credentials_bucket_name,
  $credentials_bucket_region = "us-east-1",
  $path_to_ssh_keys = "ssh-keys",
  $application_path = "$defaults::paths::application_base/user_auth",
) {
    file { $application_path:
      ensure => directory,
    } ->
    file { "$application_path/sync_users.rb":       
      content => template('user-auth/sync_users.rb'),     
    } ->     
    file { "$application_path/update_user_template.pp":       
      source => "puppet:///modules/user-auth/update_user_template.pp",      
    } ->
    file { "$application_path/public_keys":
      ensure => directory,
    } ->
    exec { "Create SSH users":
      command => "ruby ${application_path}/sync_users.rb",
      require => Exec["check if instance profile credentials are available"],
      timeout => 500,
    }
    cron { "Sync SSH users every 5 minutes":
      command => "ruby ${application_path}/sync_users.rb",
      minute => "*/5",
    }
    file { "/etc/sudoers":
      source => "puppet:///modules/user-auth/sudoers",
      owner => "root",
      group => "root",
    }
}
