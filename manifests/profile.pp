# === Example
#
# awsshell::profile { 'default':
#   user                  => '',
#   aws_access_key_id     => '',
#   aws_secret_access_key => '',
#   aws_region            => '',
#   output                => 'json',
# }
#

define awsshell::profile(
  $user                  = 'root',
  $group                 = undef,
  $homedir               = undef,
  $aws_access_key_id     = undef,
  $aws_secret_access_key = undef,
  $aws_region            = 'us-east-1',
  $output                = 'json',
) {
  if $aws_access_key_id == undef and $aws_secret_access_key == undef {
    info ('AWS keys for awscli::profile. Your will need IAM roles configured.')
    $skip_credentials = true
  }

  if $homedir {
    $homedir_real = $homedir
  } else {
    if $user != 'root' {
      $homedir_real = "/Users/${user}"
    } else {
      $homedir_real = '/root'
    }
  }

  if ($group == undef) {
    if $user != 'root' {
      $group_real = staff
    } else {
      $group_real = 'root'
    }
  } else {
    $group_real = $group
  }

  # ensure $homedir/.aws is available
  if !defined(File["${homedir_real}/.aws"]) {
    file { "${homedir_real}/.aws":
      ensure => 'directory',
      owner  => $user,
      group  => $group_real
    }
  }

  # setup credentials
  if ! $skip_credentials {
    if !defined(Concat["${homedir_real}/.aws/credentials"]) {
      concat { "${homedir_real}/.aws/credentials":
        ensure => 'present',
        owner  => $user,
        group  => $group_real
      }
    }

    concat::fragment { "${title}-credentials":
      target  => "${homedir_real}/.aws/credentials",
      content => template('awscli/credentials_concat.erb')
    }
  }

  # setup config
  if !defined(Concat["${homedir_real}/.aws/config"]) {
    concat { "${homedir_real}/.aws/config":
      ensure => 'present',
      owner  => $user,
      group  => $group_real
    }
  }

  concat::fragment { "${title}-config":
    target  => "${homedir_real}/.aws/config",
    content => template('awscli/config_concat.erb')
  }
}

