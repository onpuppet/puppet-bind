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

  $config_dir = "$config_dir/named.conf"

  $config_file_owner = $::osfamily ? {
    'RedHat'  => 'root',
    'Debian'  => 'bind',
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

