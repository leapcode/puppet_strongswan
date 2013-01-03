# strongswan on centos six
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

  file{ [ '/etc/strongswan/ipsec.d',
          '/etc/strongswan/ipsec.d/private',
          '/etc/strongswan/ipsec.d/certs' ]:
    ensure  => directory,
    require => Package['strongswan'],
    before  => Exec['ipsec_privatekey'],
    owner   => root,
    group   => 0,
    mode    => '0600';
  }

  file{'/etc/sysconfig/strongswan':
    content => "config='/etc/strongswan/strongswan.conf'\n",
    notify  => Service['ipsec'],
    owner   => 'root',
    group   => 0,
    mode    => 0644;
  }
}
