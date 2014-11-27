# == Define dns::record::prt
#
# Wrapper for dns::record to set PTRs
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
