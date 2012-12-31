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

  File {
    require => Package['strongswan'],
    notify  => Service['ipsec'],
    owner   => 'root',
    group   => 0,
    mode    => '0400',
  }

  file{
    '/etc/ipsec.secrets':
      content => ": RSA ${::fqdn}.pem\n";
    # this is needed because if the glob-include in the config
    # doesn't find anything it fails.
    "${strongswan::config_dir}/ipsec.hosts.__dummy__.conf":
      ensure  => 'present';
    '/etc/ipsec.conf':
      content => template('strongswan/ipsec.conf.erb');
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
