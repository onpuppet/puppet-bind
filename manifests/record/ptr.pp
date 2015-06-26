# == Define dns::record::prt
#
# Wrapper for dns::record to set PTRs
#
# === Parameters
#
# [*zone*]
#   Zone name for record
# [*data*]
#   Data to set for host
# [*ttl*]
#   Time to live for record
# [*host*]
#   Hostname for record
#
define bind::record::ptr (
  $zone,
  $data,
  $ttl = '',
  $host = $name
) {

  $alias = "${host},PTR,${zone}"
# FIXME -- use nsupdate instead of manipulating zonefile directly
  bind::record { $alias:
    zone   => $zone,
    host   => $host,
    ttl    => $ttl,
    record => 'PTR',
    data   => "${data}."
  }
}
