# Class: bind::params
#
class bind::params {
  $bindlogdir = '/var/log/named'

  $config_dir = $::osfamily ? {
    'RedHat'  => '/etc/named',
    'Debian'  => '/etc/bind',
    'FreeBSD' => '/etc/bind',
    default   => '/etc/bind',
  }

  $directory = $::osfamily ? {
    'Debian' => '/var/cache/bind',
    default => '/var/named'
  }

  $config_file = "${config_dir}/named.conf"

  $binkey_file = $::osfamily ? {
    'RedHat' => '/etc/named.iscdlv.key',
    'Debian' => '/etc/bind/bind.keys',
    default  => '/etc/bind/bind.keys',
  }

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

  $packagename = $::osfamily ? {
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
}

