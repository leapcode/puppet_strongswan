# configure a simple remote host
define strongswan::remote_host(
  $right_ip_address,
  $right_subnet       = [],
  $ensure             = 'present',
  $left_id            = 'absent',
  $left_ip_address    = 'absent',
  $left_subnet        = [],
  $right_id           = $name,
  $right_cert_name    = $name,
  $right_cert_content = 'absent'
){
  file{"${strongswan::config_dir}/hosts/${name}.conf":
    ensure  => $ensure,
    require => Package['strongswan'],
    notify  => Service['ipsec'],
  }

  if $ensure == 'present' {
    File["${strongswan::config_dir}/hosts/${name}.conf"]{
      content => template('strongswan/remote_host.erb'),
      owner   => 'root',
      group   => 0,
      mode    => '0400',
    }
  }

  if $right_cert_content != 'unmanaged' {
    strongswan::cert{$right_cert_name: }
    if ($right_cert_content != 'absent') and ($ensure == 'present') {
      Strongswan::Cert[$right_cert_name]{
        ensure  => $ensure,
        cert    => $right_cert_content,
      }
    } else {
      Strongswan::Cert[$right_cert_name]{
        ensure => 'absent',
      }
    }
  }
}
