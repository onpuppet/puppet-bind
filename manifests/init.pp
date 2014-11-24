# Class: bind
#
# Install and enable an ISC BIND server.
#
# Sample Usage :
#  class { 'bind':
#    lister_on_addr    => ['any'],
#    listen_on_v6_addr => ['any'],
#  }
#
class bind (
  $acls                   = {
  }
  ,
  $masters                = {
  }
  ,
  $listen_on_port         = $bind::params::listen_on_port,
  $listen_on_addr         = $bind::params::listen_on_addr,
  $listen_on_v6_port      = $bind::params::listen_on_v6_port,
  $listen_on_v6_addr      = $bind::params::listen_on_v6_addr,
  $forwarders             = $bind::params::forwarders,
  $config_dir             = $bind::params::config_dir,
  $directory              = $bind::params::directory,
  $managed_keys_directory = undef,
  $hostname               = undef,
  $server_id              = undef,
  $version                = undef,
  $log_level              = 'info',
  $dump_file              = '/var/named/data/cache_dump.db',
  $statistics_file        = '/var/named/data/named_stats.txt',
  $memstatistics_file     = '/var/named/data/named_mem_stats.txt',
  $allow_query            = $bind::params::allow_query,
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
  $includes               = $bind::params::includes,
  $views                  = {
  }
  ,
  $service_reload         = true,
  $package                = $bind::params::package,
  $bindlogdir             = $bind::params::bindlogdir,
  $servicename            = $bind::params::servicename,
  $source                 = $bind::params::source,
  $template               = $bind::params::template,
  $config_file            = $bind::params::config_file,
  $config_file_mode       = $bind::params::config_file_mode,
  $config_file_owner      = $bind::params::config_file_owner,
  $config_file_group      = $bind::params::config_file_group,
  $key                    = undef,
  $secret                 = undef,
  $controls               = [],
  $inet                   = '127.0.0.1',
  $inet_port              = '953',
  $bindkey_file           = $bind::params::bindkey_file,
  $allow_notify           = [],) inherits bind::params {
  class { 'bind::install': } ->
  class { 'bind::config': } ~>
  class { 'bind::service': } ->
  Class['bind']
}

