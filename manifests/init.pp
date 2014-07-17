# Class: bind
#
# Install and enable an ISC BIND server.
#
# Parameters:
#  $chroot:
#   Enable chroot for the server. Default: false
#  $packageprefix:
#   Package prefix name. Default: 'bind' or 'bind9' depending on the OS
#
# Sample Usage :
#  include bind
#  class { 'bind':
#    chroot            => true,
#    packageprefix => 'bind97',
#  }
#
class bind (
  $acls                   = {
  }
  ,
  $masters                = {
  }
  ,
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
  $extra_options          = {
  }
  ,
  $dnssec_enable          = 'yes',
  $dnssec_validation      = 'yes',
  $dnssec_lookaside       = 'auto',
  $zones                  = {
  }
  ,
  $includes               = [],
  $views                  = {
  }
  ,
  $service_reload         = true,
  $package                = $::bind::params::package,
  $bindlogdir             = $::bind::params::bindlogdir,
  $servicename            = $::bind::params::servicename,
  $source                 = $::bind::params::source,
  $template               = $::bind::params::template,
  $config_file            = $::bind::params::config_file,
  $config_file_mode       = $::bind::params::config_file_mode,
  $config_file_owner      = $::bind::params::config_file_owner,
  $config_file_group      = $::bind::params::config_file_group,
  $key                    = undef,
  $controls               = [],
  $inet                   = '127.0.0.1',
  $inet_port              = '953',
  $bindkey_file           = $::bind::params::binkey_file,
  $allow_notify           = [],) inherits ::bind::params {
  if ($::bind::source and $::bind::template) {
    fail('Bind: cannot set both source and template')
  }

  $manage_file_source = $::bind::source ? {
    ''      => undef,
    default => $::bind::source,
  }

  $manage_file_content = $::bind::template ? {
    ''      => undef,
    default => template($::bind::template),
  }

  file { $::bind::config_file:
    ensure  => present,
    owner   => $::bind::config_file_owner,
    group   => $::bind::config_file_group,
    mode    => $::bind::config_file_mode,
    source  => $::bind::manage_file_source,
    content => $::bind::manage_file_content,
    notify  => Service[$::bind::servicename],
    require => Package[$::bind::package],
  }

  file { "${::bind::config_dir}/zones":
    ensure  => directory,
    owner   => $::bind::config_file_owner,
    group   => $::bind::config_file_group,
    mode    => '0755',
    require => Package[$::bind::package],
  }

  concat { "${::bind::config_dir}/named.conf.local":
    owner   => $::bind::config_file_owner,
    group   => $::bind::config_file_group,
    mode    => '0644',
    require => [Package[$::bind::package], Class['concat::setup']],
    notify  => Service[$::bind::servicename],
  }

  concat::fragment { 'named.conf.local.header':
    ensure  => present,
    owner   => $::bind::config_file_owner,
    group   => $::bind::config_file_group,
    mode    => '0644',
    target  => "${::bind::config_dir}/named.conf.local",
    order   => 1,
    content => "// File managed by Puppet.\n",
    require => Package[$::bind::package],
  }

  # Main package and service
  package { $::bind::package: ensure => 'present' }

  service { $::bind::servicename:
    ensure     => running,
    hasstatus  => true,
    enable     => true,
    restart    => "/sbin/service ${::bind::servicename} reload",
    hasrestart => true,
    require    => Package[$::bind::package],
  }

  # We want a nice log file which the package doesn't provide a location for

  file { $::bind::bindlogdir:
    ensure  => directory,
    owner   => $::bind::config_file_owner,
    group   => $::bind::config_file_group,
    mode    => '0770',
    seltype => 'var_log_t',
    before  => Service[$::bind::servicename],
    require => Package[$::bind::package],
  }

}

