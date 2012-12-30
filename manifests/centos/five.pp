class strongswan::centos::five inherits strongswan::base {
  if $::selinux == 'true' {
    package{'strongswan-selinux':
      before => Service['ipsec'],
      ensure => installed,
    }
  }
}
