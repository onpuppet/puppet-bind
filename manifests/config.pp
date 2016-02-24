# == Class bind::config
#
# This class is called from bind
#
class bind::config {
  if ($bind::source and $bind::template) {
    fail("Bind: cannot set both source (${bind::source}) and template (${bind::template})")
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
  }

  exec { 'named-checkconf':
    command     => "/usr/sbin/named-checkconf ${bind::config_file}",
    refreshonly => true,
    logoutput   => true,
    require     => File[$bind::config_file],
  }

  concat { "${bind::config_dir}/named.conf.local":
    require => [Package[$bind::package], Class['concat::setup']],
    owner   => $bind::config_file_owner,
    group   => $bind::config_file_group,
    mode    => $bind::config_file_mode,
    notify  => Exec['named-checkconf'],
  }

  concat::fragment { 'named.conf.local.header':
    target  => "${bind::config_dir}/named.conf.local",
    order   => 1,
    content => "// File managed by Puppet.\n",
  }

  # Zones
  file { $bind::data_dir:
    ensure => directory,
    owner  => $bind::config_file_owner,
    group  => $bind::config_file_group,
    mode   => '0775',
  }

  if empty($bind::masters) {
    $fqdn_hash = {
      "${::fqdn} " => $::fqdn
    }
    $nameserver_hash = merge($bind::masters, $fqdn_hash)
    $defaults = {
      'nameservers'             => keys($nameserver_hash),
      'zone_type'               => 'slave',
      'slave_masters'           => keys($bind::masters),
      'allow_update_forwarding' => [$bind::key],
    }
  } else {
    $defaults = {
      'nameservers'    => [$::fqdn, $bind::allow_notify],
      'zone_type'      => 'master',
      'allow_transfer' => [$bind::allow_notify],
      'allow_update'   => [$bind::key],
    }
  }

  create_resources(bind::zone, $bind::zones, $defaults)

  # Log folder
  file { $bind::bindlogdir:
    ensure  => directory,
    owner   => $bind::config_file_owner,
    group   => $bind::config_file_group,
    mode    => '0770',
    seltype => 'var_log_t',
  }

  # Rndc key
  $real_keyname = $bind::key ? {
    undef   => 'rndc-key',
    ''      => 'rndc-key',
    default => $bind::key,
  }

  bind::key { $real_keyname: secret => $bind::secret, }
}
