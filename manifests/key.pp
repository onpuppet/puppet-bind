# = Definition: bind::key
#
# Helper to manage dns keys (NOT dnssec)
# used mainly for nsupdate (dynamic updates)
#
# Arguments:
# *$secret*: key content
# *$algorithm*: key algorithm. Default hmac-md5
#
# This definition does NOT generate the key, please refer
# to Bind9 documentation regarding dynamic update setup and
# key pair generation.
#
define bind::key ($secret, $ensure = present, $algorithm = 'hmac-md5',) {
  validate_string($ensure)
  validate_re($ensure, ['present', 'absent'], "\$ensure must be either 'present' or 'absent', got '${ensure}'")

  validate_string($algorithm)
  validate_string($secret)

  file { "${::bind::config_dir}/${name}":
    ensure  => $ensure,
    mode    => $bind::config_file_mode,
    owner   => $bind::params::config_file_owner,
    group   => $bind::params::config_file_group,
    content => template("${module_name}/dnskey.conf.erb"),
    require => Package[$::bind::package],
  }

  concat::fragment { "dnskey.${name}":
    ensure  => $ensure,
    target  => "${bind::config_dir}/named.conf.local",
    content => "include \"${bind::params::config_dir}/${name}\";\n",
    notify  => Service[$::bind::servicename],
    require => Package[$::bind::package],
  }

}
