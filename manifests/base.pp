# manage strongswan services
class strongswan::base {

  package{'strongswan':
    ensure => installed,
  }

  if $::selinux == 'true' {
    package{'strongswan-selinux':
      ensure => installed,
    }
  }

  exec{
    'ipsec_privatekey':
      command => "certtool --generate-privkey --bits 2048 --outfile /etc/ipsec.d/private/${::fqdn}.pem",
      creates => "/etc/ipsec.d/private/${::fqdn}.pem",
      require => Package['strongswan'];
    'ipsec_monkeysphere_cert':
      command => "monkeysphere-host import-key /etc/ipsec.d/private/${::fqdn}.pem ike://${::fqdn} && gpg --homedir /var/lib/monkeysphere/host -a --export =ike://${::fqdn} > /etc/ipsec.d/certs/${::fqdn}.asc";
      creates => "/etc/ipsec.d/certs/${::fqdn}.asc",
      require => Exec['ipsec_privatekey'];
  }

  file{ '/etc/ipsec.secrets':
      content => ": RSA ${::fqdn}.pem\n",
      require => Package['strongswan'],
      notify  => Service['ipsec'],
      owner   => 'root',
      group   => 0,
      mode    => '0400';
    '/etc/ipsec.conf':
      source  => "puppet:///modules/site_strongswan/configs/${::fqdn}",
      require => Package['strongswan'],
      notify  => Service['ipsec'],
      owner   => 'root',
      group   => 0,
      mode    => '0400';
  }

  service{'ipsec':
    ensure => running,
    enable => true,
  }

  if $::strongswan_cert != 'false' and $::strongswan_cert != '' {
    @@file{"/etc/ipsec.d/certs/${::fqdn}.asc":
      tag     => 'strongswan_cert',
      content => $::strongswan_cert,
      require => Package['strongswan'],
      notify  => Service['ipsec'],
      owner   => 'root',
      group   => 0,
      mode    => '0400';
    }
  }

  File<<| tag == 'strongswan_cert' |>>

}
