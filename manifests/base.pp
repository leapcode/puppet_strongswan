# manage strongswan services
class strongswan::base {

  package{'strongswan':
    ensure => installed,
  } -> exec{
    'ipsec_privatekey':
      command => "certtool --generate-privkey --bits 2048 --outfile ${strongswan::config_dir}/private/${::fqdn}.pem",
      creates => "${strongswan::config_dir}/private/${::fqdn}.pem";
  } -> exec{'ipsec_monkeysphere_cert':
      command => "monkeysphere-host import-key ${strongswan::config_dir}/private/${::fqdn}.pem ike://${::fqdn} && gpg --homedir /var/lib/monkeysphere/host -a --export =ike://${::fqdn} > ${strongswan::config_dir}/certs/${::fqdn}.asc",
      creates => "${strongswan::config_dir}/certs/${::fqdn}.asc",
  }

  file{
    '/etc/ipsec.secrets':
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
    @@strongswan::cert{$::fqdn:
      cert => $::strongswan_cert,
      tag  => 'strongswan_cert'
    }
  }

  Strongswan::Cert<<| tag == 'strongswan_cert' |>>
}
