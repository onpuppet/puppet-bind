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
#
# === Parameters
#
# [*ensure*]
#   Ensure keyword for zone file
# [*soa*]
#   SOA for zone
# [*soa_email*]
#   Email for SOA
# [*zone_ttl*]
#   Default ttl for zone
# [*zone_refresh*]
#   Zone refresh parameter
# [*zone_retry*]
#   Zone retry parameter
# [*zone_expire*]
#   Zone expire parameter
# [*zone_minimum*]
#   Zone minimum parameter
# [*nameservers*]
#   Nameserver authorative for this zone
# [*reverse*]
#   If zone type is reverse set this to true
# [*zone_type*]
#   Type of zone
# [*allow_transfer*]
#   Array of hosts allowed to do zone transfer
# [*allow_forwarder*]
#   Array of hosts allowed for zone forwarder
# [*forward_policy*]
#   Zone forward policy
# [*allow_update*]
#   Array of hosts and keys allowed to update
# [*allow_update_forwarding*]
#   Array of hosts and keys allowed to update with forwarding to master
# [*slave_masters*]
#   Array of slaves for zone
# [*zone_notify*]
#   Allow zone notify
# [*view_name*]
#   If set, the zone declaration is put in a separate named.conf.view file
#
define bind::zone (
  $ensure                  = present,
  $soa                     = $::fqdn,
  $soa_email               = "root.${::fqdn}",
  $zone_ttl                = '1800',
  $zone_refresh            = '7200',
  $zone_retry              = '1800',
  $zone_expire             = '86400',
  $zone_minimum            = '1800',
  $nameservers             = [$::fqdn],
  $reverse                 = false,
  $zone_type               = 'master',
  $allow_transfer          = [],
  $allow_forwarder         = [],
  $forward_policy          = 'first',
  $allow_update            = [],
  $allow_update_forwarding = [],
  $slave_masters           = [],
  $zone_notify             = false,
  $view_name               = undef,
) {
  validate_array($allow_transfer)
  validate_array($allow_forwarder)
  validate_array($allow_update)
  validate_array($allow_update_forwarding)
  validate_array($slave_masters)

  if !member(['first', 'only'], $forward_policy) {
    fail('The forward policy can only be set to either first or only')
  }

  $zone = $reverse ? {
    true    => "${name}.IN-ADDR.ARPA",
    default => $name
  }

  $zone_file = "${::bind::data_dir}/${name}"
  $zone_file_stage = "${zone_file}.stage"

  # FIXME -- file { replace = false } + dynamic records instead of stage and exec

  if $ensure == absent {
    file { $zone_file: ensure => absent, }
  } else {
    # Zone Database

    # Create "fake" zone file without zone-serial
    concat { $zone_file_stage:
      owner   => $::bind::config_file_owner,
      group   => $::bind::config_file_group,
      mode    => '0644',
      require => Package[$::bind::package],
      notify  => Exec["bump-${zone}-serial"],
    }

    concat::fragment { "${name}.soa":
      target  => $zone_file_stage,
      order   => 1,
      content => template("${module_name}/zone_file.erb"),
    }

    # Generate real zone from stage file through replacement _SERIAL_ template
    # to current timestamp. A real zone file will be updated only at change of
    # the stage file, thanks to this serial is updated only in case of need.
    $zone_serial = inline_template('<%= Time.now.to_i %>')

    exec { "bump-${zone}-serial":
      command     => "sed 's/_SERIAL_/${zone_serial}/' ${zone_file_stage} > ${zone_file}; echo '' >> ${zone_file}",
      path        => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
      refreshonly => true,
      provider    => posix,
      user        => $::bind::config_file_owner,
      group       => $::bind::config_file_group,
      require     => Package[$::bind::package],
      notify      => Service[$::bind::servicename],
    }

    if $zone_type == 'master' {
      # Slave use faster binary format for zones by default since Bind 9.9
      Exec <| title == "bump-${zone}-serial" |> {
        notify +> Exec["named-checkzone-${zone}"],
      }

      exec { "named-checkzone-${zone}":
        command     => "/usr/sbin/named-checkzone ${name} ${zone_file}",
        refreshonly => true,
        logoutput   => true,
        require     => Exec["bump-${zone}-serial"],
      }
    }
  }

  # Include Zone in named.conf.local or name.conf.view.${view_name}
  $concat_target = $view_name ? {
    undef   => "${::bind::config_dir}/named.conf.local",
    default => "${::bind::config_dir}/named.conf.view.${view_name}",
  }

  if !defined(Concat[$concat_target]) {
    concat { $concat_target:
      require => [Package[$bind::package]],
      owner   => $bind::config_file_owner,
      group   => $bind::config_file_group,
      mode    => $bind::config_file_mode,
    }
  }

  concat::fragment { "named.conf.local.${name}.include":
    target  => $concat_target,
    order   => 3,
    content => template("${module_name}/zone.erb"),
    require => Package[$::bind::package],
  }

}
