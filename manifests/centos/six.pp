class strongswan::centos::six inherits strongswan::base {
  Service['ipsec']{
    name => 'strongswan',
  }
  file{'/etc/selinux/strongswan':
    content => "config='/etc/strongswan/strongswan.conf'\n",
    notify  => Service['ipsec'],
    owner   => 'root',
    group   => 0,
    mode    => 0644;
  }
}
