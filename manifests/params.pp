# Class: bind::params
#
class bind::params {
  $acls = {
  }
  $masters = {
  }
  $managed_keys_directory = undef
  $hostname = undef
  $server_id = undef
  $version = undef
  $log_level = 'info'
  $dump_file = '/var/named/data/cache_dump.db'
  $statistics_file = '/var/named/data/named_stats.txt'
  $memstatistics_file = '/var/named/data/named_mem_stats.txt'
  $allow_query = ['any']
  $allow_query_cache = []
  $recursion = 'yes'
  $allow_recursion = []
  $allow_transfer = []
  $check_names = []
  $extra_options = {
  }
  $dnssec_enable = 'yes'
  $dnssec_validation = 'yes'
  $dnssec_lookaside = 'auto'
  $zones = {
  }
  $includes = []
  $views = {
  }
  $service_reload = true
  $bindlogdir = '/var/log/named'
  $listen_on_port = 53
  $listen_on_addr = ['any']
  $listen_on_v6_port = 53
  $listen_on_v6_addr = ['any']

  $forwarders = ['8.8.8.8', '8.8.4.4']

  $config_dir = $::osfamily ? {
    'RedHat'  => '/etc/named',
    'Debian'  => '/etc/bind',
    'FreeBSD' => '/etc/bind',
    default   => '/etc/bind',
  }

  $directory = $::osfamily ? {
    'Debian' => '/var/cache/bind',
    default  => '/var/named'
  }

  $source = ''

  $template = 'bind/named.conf.erb'

  $config_file = "${config_dir}/named.conf"

  $bindkey_file = $::osfamily ? {
    'RedHat' => '/etc/named.iscdlv.key',
    'Debian' => '/etc/bind/bind.keys',
    default  => '/etc/bind/bind.keys',
  }

  $config_file_mode = '0644'

  $config_file_owner = $::osfamily ? {
    'RedHat'  => 'root',
    'Debian'  => 'root',
    'FreeBSD' => 'bind',
    default   => 'root',
  }

  $config_file_group = $::osfamily ? {
    'RedHat'  => 'named',
    'Debian'  => 'bind',
    'FreeBSD' => 'bind',
    default   => 'named',
  }

  $package = $::osfamily ? {
    'RedHat'  => 'bind',
    'Debian'  => 'bind9',
    'FreeBSD' => 'bind910',
    default   => 'bind',
  }

  $servicename = $::osfamily ? {
    'RedHat'  => 'named',
    'Debian'  => 'bind9',
    'FreeBSD' => 'named',
    default   => 'named',
  }

  $key = undef
  $secret = undef
  $controls = []
  $inet = '127.0.0.1'
  $inet_port = '953'
  $allow_notify = []

}
