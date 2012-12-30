# manage a cert snippet that we want to include
define strongswan::cert($cert) {
  file{"${strongswan::config_dir}/certs/${name}.asc":
    content => $cert,
    require => Package['strongswan'],
    notify  => Service['ipsec'],
    owner   => 'root',
    group   => 0,
    mode    => '0400';
  }
}
