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
  $acls                   = $bind::params::acls,
  $masters                = $bind::params::masters,
  $listen_on_port         = $bind::params::listen_on_port,
  $listen_on_addr         = $bind::params::listen_on_addr,
  $listen_on_v6_port      = $bind::params::listen_on_v6_port,
  $listen_on_v6_addr      = $bind::params::listen_on_v6_addr,
  $forwarders             = $bind::params::forwarders,
  $config_dir             = $bind::params::config_dir,
  $data_dir               = $bind::params::data_dir,
  $directory              = $bind::params::directory,
  $managed_keys_directory = $bind::params::managed_keys_directory,
  $hostname               = $bind::params::hostname,
  $server_id              = $bind::params::server_id,
  $version                = $bind::params::version,
  $log_level              = $bind::params::log_level,
  $dump_file              = $bind::params::dump_file,
  $statistics_file        = $bind::params::statistics_file,
  $memstatistics_file     = $bind::params::memstatistics_file,
  $allow_query            = $bind::params::allow_query,
  $allow_query_cache      = $bind::params::allow_query_cache,
  $recursion              = $bind::params::recursion,
  $allow_recursion        = $bind::params::allow_recursion,
  $allow_transfer         = $bind::params::allow_transfer,
  $check_names            = $bind::params::check_names,
  $extra_options          = $bind::params::extra_options,
  $dnssec_enable          = $bind::params::dnssec_enable,
  $dnssec_validation      = $bind::params::dnssec_validation,
  $dnssec_lookaside       = $bind::params::dnssec_lookaside,
  $zones                  = $bind::params::zones,
  $includes               = $bind::params::includes,
  $views                  = $bind::params::views,
  $service_reload         = $bind::params::service_reload,
  $package                = $bind::params::package,
  $bindlogdir             = $bind::params::bindlogdir,
  $servicename            = $bind::params::servicename,
  $source                 = $bind::params::source,
  $template               = $bind::params::template,
  $config_file            = $bind::params::config_file,
  $config_file_mode       = $bind::params::config_file_mode,
  $config_file_owner      = $bind::params::config_file_owner,
  $config_file_group      = $bind::params::config_file_group,
  $key                    = $bind::params::key,
  $secret                 = $bind::params::secret,
  $controls               = $bind::params::controls,
  $inet                   = $bind::params::inet,
  $inet_port              = $bind::params::inet_port,
  $bindkey_file           = $bind::params::bindkey_file,
  $allow_notify           = $bind::params::allow_notify,) inherits bind::params {
  class { 'bind::install': } ->
  class { 'bind::config': } ~>
  class { 'bind::service': } ->
  Class['bind']
}

