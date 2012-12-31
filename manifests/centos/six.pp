class strongswan::centos::six inherits strongswan::base {
  Service['ipsec']{
    name => 'strongswan',
  }
  File['/etc/ipsec.secrets']{
    path => '/etc/strongswan/ipsec.secrets'
  }
  File['/etc/ipsec.conf']{
    path => '/etc/strongswan/ipsec.conf'
  }

  file{'/etc/selinux/strongswan':
    content => "config='/etc/strongswan/strongswan.conf'\n",
    notify  => Service['ipsec'],
    owner   => 'root',
    group   => 0,
    mode    => 0644;
  }
}
