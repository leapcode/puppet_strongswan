# manage a cert snippet that we want to include
define strongswan::cert (
  $ensure = 'present',
  $cert   = 'absent'
) {
  if ($cert == 'absent') and ($ensure == 'present'){
    fail("You need to pass some \$cert content for ${name} if it should be present")
  }

  file { "${strongswan::cert_dir}/certs/${name}.asc":
    ensure  => $ensure,
    require => Package['strongswan'],
    notify  => Service['ipsec'],
  }

  if $ensure == 'present' {
    File["${strongswan::cert_dir}/certs/${name}.asc"]{
      content => $cert,
      owner   => 'root',
      group   => 0,
      mode    => '0400',
    }
  }
}
