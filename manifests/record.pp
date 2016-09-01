# == Define dns::record
#
# This is a private class to arbitary dns records.
#
# === Parameters
#
# [*zone*]
#   Zone name for record
# [*host*]
#   Hostname
# [*data*]
#   Data to set for host
# [*record*]
#   Type of DNS record
# [*dns_class*]
#   Class type of record
# [*ttl*]
#   Time to live for record
# [*preference*]
#   Preference for record
# [*order*]
#   Order number for record
#
define bind::record (
  $zone,
  $host,
  $data,
  $record = 'A',
  $dns_class = 'IN',
  $ttl = '',
  $preference = false,
  $order = 9
) {

  $zone_file_stage = "${bind::data_dir}/${zone}.stage"

  concat::fragment{"${zone}.${name}.record":
    target  => $zone_file_stage,
    order   => $order,
    content => template("${module_name}/zone_record.erb"),
  }

}
