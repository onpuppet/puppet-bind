# == Class bind::install
#
class bind::install {
  package { $bind::package: ensure => 'present' }
}
