# == Class bind::config
#
# This class is called from bind
#
class bind::config {
  if ($bind::source and $bind::template) {
    fail('Bind: cannot set both source and template')
  }

  $manage_file_source = $bind::source ? {
    ''      => undef,
    default => $bind::source,
  }

  $manage_file_content = $bind::template ? {
    ''      => undef,
    default => template($bind::template),
  }

  file { $bind::config_file:
    ensure  => present,
    owner   => $bind::config_file_owner,
    group   => $bind::config_file_group,
    mode    => $bind::config_file_mode,
    source  => $manage_file_source,
    content => $manage_file_content,
    notify  => Exec['named-checkconf'],
  }

  exec { 'named-checkconf':
    command     => "/usr/sbin/named-checkconf ${bind::config_file}",
    refreshonly => true,
    require     => File[$bind::config_file],
  }

  file { "${bind::config_dir}/zones":
    ensure => directory,
    owner  => $bind::config_file_owner,
    group  => $bind::config_file_group,
    mode   => '0775',
  }

  concat { "${bind::config_dir}/named.conf.local":
    require => [Package[$bind::package], Class['concat::setup']],
    notify  => Service[$bind::servicename],
    owner   => $bind::config_file_owner,
    group   => $bind::config_file_group,
    mode    => $bind::config_file_mode,
  }

  concat::fragment { 'named.conf.local.header':
    ensure  => present,
    target  => "${bind::config_dir}/named.conf.local",
    order   => 1,
    content => "// File managed by Puppet.\n",
  }

  # Log folder
  file { $bind::bindlogdir:
    ensure  => directory,
    owner   => $bind::config_file_owner,
    group   => $bind::config_file_group,
    mode    => '0770',
    seltype => 'var_log_t',
  }

  # Rndc key
  if ($bind::secret) {
    $real_keyname = $bind::key ? {
      undef   => 'rndc-key',
      ''      => 'rndc-key',
      default => $bind::key,
    }

    bind::key { $real_keyname: secret => $bind::secret, }
  }

}
