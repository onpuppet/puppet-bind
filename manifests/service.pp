# == Class bind::service
#
# This class is meant to be called from bind
# It ensure the service is running
#
class bind::service {
  $service_location = $::osfamily ? {
    default => '/sbin/service',
    Debian  => '/usr/sbin/service'
  }

  service { $bind::servicename:
    ensure     => running,
    hasstatus  => true,
    enable     => true,
    restart    => "${service_location} ${bind::servicename} reload",
    hasrestart => true,
    require    => Package[$bind::package],
  }
}
