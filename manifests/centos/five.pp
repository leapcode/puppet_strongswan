# strongswan on centos 5
class strongswan::centos::five inherits strongswan::base {
  if $::selinux == 'true' {
    package{'strongswan-selinux':
      ensure => installed,
      before => Service['ipsec'],
    }
  }
}
