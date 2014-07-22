# Class: bind::params
#
class bind::params {
  $bindlogdir = '/var/log/named'


  $listen_on_port = 53
  $listen_on_addr = ['any']
  $listen_on_v6_port = 53
  $listen_on_v6_addr = ['any']
  $allow_query = ['any']

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

  $includes = ["$config_dir/named.conf.local", "$config_dir/named.conf.default-zones"]

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
  } }

