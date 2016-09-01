# == Class: bind
#
# Install and enable an ISC BIND server.
#
# === Sample Usage :
#  class { 'bind':
#    lister_on_addr    => ['any'],
#    listen_on_v6_addr => ['any'],
#  }
#
# === Parameters
#
# [*acls*]
#   Bind acl clause
# [*masters*]
#   Array of Bind master servers
# [*listen_on_port*]
#   The port used for IPv4
# [*listen_on_addr*]
#   Address to listen to for IPv4
# [*listen_on_v6_port*]
#   Address to listen to for IPv6
# [*listen_on_v6_addr*]
#   Address to listen to for IPv6
# [*forwarders*]
#   DNS servers to forward non authorative domains to
# [*config_dir*]
#   Directory where config files live
# [*data_dir*]
#   Directory where DNS data such as journal files are stored
# [*directory*]
#   Running directory and where temporary files are stored
# [*managed_keys_directory*]
#   Directory where managed keys are
# [*hostname*]
#   Hostname of server
# [*server_id*]
#   Id of server
# [*version*]
#   What version of Bind to install
# [*log_level*]
#   Level og logging verbosity
# [*dump_file*]
#   Location of Bind dump file
# [*statistics_file*]
#   Location of statistics file
# [*memstatistics_file*]
#   Location of memstatistics file
# [*allow_query*]
#   Hosts and keys allowed to query server
# [*allow_query_cache*]
#   Hosts and keys allowed to modify cache
# [*recursion*]
#   Enable recursion
# [*allow_recursion*]
#   Hosts and keys allowed to do recursive lookups
# [*allow_transfer*]
#   Hosts and keys allowed to do zone transfer
# [*check_names*]
#   Enable bind check_names flag
# [*extra_options*]
#   Custom options to bind config
# [*dnssec_enable*]
#   Enable dnssec
# [*dnssec_validation*]
#   Dnssec validation config option
# [*dnssec_lookaside*]
#   Dnssec lookaside option
# [*zones*]
#   Hash of zones to configure for bind
# [*includes*]
#   Config files to include
# [*views*]
#   Bind views config option
# [*service_reload*]
#   Enable service reload on config update
# [*package*]
#   Bind package name to install
# [*bindlogdir*]
#   Directory to store log files in
# [*servicename*]
#   Name of bind service
# [*source*]
#   Configuration source file
# [*template*]
#   Configuration template
# [*config_file*]
#   Configuration file path
# [*config_file_mode*]
#   File mode for config file
# [*config_file_owner*]
#   Config file owner
# [*config_file_group*]
#   Config file owning group
# [*key*]
#   Name of rndc update key
# [*secret*]
#   Key secret (password) of rndc key
# [*controls*]
#   Array of servers allowed for control function
# [*inet*]
#   Interface to bind to
# [*inet_port*]
#   Interface port to bind to
# [*bindkey_file*]
#   File location of bind key
# [*allow_notify*]
#   Array of hosts allowed the notify keyword
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
  $allow_notify           = $bind::params::allow_notify,
) inherits bind::params {

  validate_string($server_id)

  class { '::bind::install': } ->
  class { '::bind::config': } ~>
  class { '::bind::service': } ->
  Class['::bind']
}

