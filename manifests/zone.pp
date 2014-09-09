# == Define: bind::zone
#
# Example usage:
#
# Forward zone file for master
#
#    bind::zone { 'example.com':
#      soa            => 'ns1.example.com',
#      soa_email      => 'noreply@example.com',
#      nameservers    => ["ns1.example.com", "ns2.example.com"],
#      allow_transfer => ['10.0.0.0/8'],
#      zone_notify    => 'yes',
#      allow_update   => $allow_update,
#    }
define bind::zone (
  $soa = "${::fqdn}",
  $soa_email = "root.${::fqdn}",
  $zone_ttl = '604800',
  $zone_refresh = '604800',
  $zone_retry = '86400',
  $zone_expire = '2419200',
  $zone_minimum = '604800',
  $nameservers = [ $::fqdn ],
  $reverse = false,
  $zone_type = 'master',
  $allow_transfer = [],
  $allow_forwarder = [],
  $forward_policy = 'first',
  $allow_update = false,
  $slave_masters = [],
  $zone_notify = false,
  $ensure = present,
) {

  validate_array($allow_transfer)
  validate_array($allow_forwarder)


  if !empty($bind::forwarders) and !empty($allow_forwarder) {
    fail("You cannot specify a global forwarder and \
    a zone forwarder for zone ${soa}")
  }
  if !member(['first', 'only'], $forward_policy) {
    fail('The forward policy can only be set to either first or only')
  }

  $zone = $reverse ? {
    true    => "${name}.IN-ADDR.ARPA",
    default => $name
  }

  $zone_file = "${::bind::config_dir}/zones/db.${name}"
  $zone_file_stage = "${zone_file}.stage"

  if $ensure == absent {
    file { $zone_file:
      ensure => absent,
    }
  } else {
    # Zone Database

    # Create "fake" zone file without zone-serial
    concat { $zone_file_stage:
      owner   => $::bind::config_file_owner,
      group   => $::bind::config_file_group,
      mode    => '0644',
      require => [Class['concat::setup'], Package[$::bind::package]],
      notify  => Exec["bump-${zone}-serial"]
    }
    concat::fragment{"db.${name}.soa":
      target  => $zone_file_stage,
      order   => 1,
      content => template("${module_name}/zone_file.erb")
    }

    # Generate real zone from stage file through replacement _SERIAL_ template
    # to current timestamp. A real zone file will be updated only at change of
    # the stage file, thanks to this serial is updated only in case of need.
    $zone_serial = inline_template('<%= Time.now.to_i %>')
    exec { "bump-${zone}-serial":
      command     => "sed '8s/_SERIAL_/${zone_serial}/' ${zone_file_stage} > ${zone_file}",
      path        => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
      refreshonly => true,
      provider    => posix,
      user        => $::bind::config_file_owner,
      group       => $::bind::config_file_group,
      require     => Package[$::bind::package],
      notify      => Service[$::bind::servicename],
    }
  }

  # Include Zone in named.conf.local
  concat::fragment{"named.conf.local.${name}.include":
    ensure  => $ensure,
    target  => "${::bind::config_dir}/named.conf.local",
    order   => 3,
    content => template("${module_name}/zone.erb"),
    require => Package[$::bind::package],
  }

}
