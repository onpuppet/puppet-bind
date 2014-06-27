# Class: bind
#
# Install and enable an ISC BIND server.
#
# Parameters:
#  $chroot:
#   Enable chroot for the server. Default: false
#  $packagenameprefix:
#   Package prefix name. Default: 'bind' or 'bind9' depending on the OS
#
# Sample Usage :
#  include bind
#  class { 'bind':
#    chroot            => true,
#    packagenameprefix => 'bind97',
#  }
#
class bind (
  $acls                   = {},
  $masters                = {},
  $listen_on_port         = '53',
  $listen_on_addr         = ['127.0.0.1'],
  $listen_on_v6_port      = '53',
  $listen_on_v6_addr      = ['::1'],
  $forwarders             = [],
  $config_dir             = $::bind::params::config_dir,
  $directory              = $::bind::params::directory,
  $managed_keys_directory = undef,
  $hostname               = undef,
  $server_id              = undef,
  $version                = undef,
  $dump_file              = '/var/named/data/cache_dump.db',
  $statistics_file        = '/var/named/data/named_stats.txt',
  $memstatistics_file     = '/var/named/data/named_mem_stats.txt',
  $allow_query            = ['localhost'],
  $allow_query_cache      = [],
  $recursion              = 'yes',
  $allow_recursion        = [],
  $allow_transfer         = [],
  $check_names            = [],
  $extra_options          = {},
  $dnssec_enable          = 'yes',
  $dnssec_validation      = 'yes',
  $dnssec_lookaside       = 'auto',
  $zones                  = {},
  $includes               = [],
  $views                  = {},
  $service_reload         = true,
  $packagename            = $::bind::params::packagename,
  $bindlogdir             = $::bind::params::bindlogdir,
  $servicename            = $::bind::params::servicename,
  $config_file            = $::bind::params::config_file,
  $config_file_owner      = $::bind::params::config_file_owner,
  $config_file_group      = $::bind::params::config_file_group,
  $key                    = undef,
  $controls               = [],
  $inet                   = '127.0.0.1',
  $inet_port              = '953',
  $bindkey_file           = $::bind::params::binkey_file,
  $allow_notify           = [],
  ) 
inherits ::bind::params {
  # Everything is inside a single template
  file { $config_file:
    notify  => Service[$servicename],
    content => template('bind/named.conf.erb'),
  }

  file { "${config_dir}/zones":
    ensure => directory,
    owner  => $config_file_owner,
    group  => $config_file_group,
    mode   => '0755',
  }

  concat { "${config_dir}/named.conf.local":
    owner   => $config_file_owner,
    group   => $config_file_group,
    mode    => '0644',
    require => Class['concat::setup'],
    notify  => Service[$servicename],
  }

  concat::fragment { 'named.conf.local.header':
    ensure  => present,
    target  => "${config_dir}/named.conf.local",
    order   => 1,
    content => "// File managed by Puppet.\n"
  }

  # Main package and service


  package { "${packagename}": ensure => installed }

  service { $servicename:
    require    => Package[$packagename],
    hasstatus  => true,
    enable     => true,
    ensure     => running,
    restart    => "service ${servicename} reload",
    hasrestart => true,
  }

  # We want a nice log file which the package doesn't provide a location for

  file { $bindlogdir:
    require => Package[$packagename],
    ensure  => directory,
    owner   => $config_file_owner,
    group   => $config_file_group,
    mode    => '0770',
    seltype => 'var_log_t',
    before  => Service[$servicename],
  }

}

