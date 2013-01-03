# manage strongswan services
class strongswan::base {

  package{'strongswan':
    ensure => installed,
  } -> exec{
    'ipsec_privatekey':
      command => "certtool --generate-privkey --bits 2048 --outfile ${strongswan::cert_dir}/private/${::fqdn}.pem",
      creates => "${strongswan::cert_dir}/private/${::fqdn}.pem";
  } -> exec{'ipsec_monkeysphere_cert':
      command => "monkeysphere-host import-key ${strongswan::crt_dir}/private/${::fqdn}.pem ike://${::fqdn} && gpg --homedir /var/lib/monkeysphere/host -a --export =ike://${::fqdn} > ${strongswan::cert_dir}/certs/${::fqdn}.asc",
      creates => "${strongswan::cert_dir}/certs/${::fqdn}.asc",
  } -> anchor{'strongswan::certs::done': }

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
    "${strongswan::config_dir}/hosts":
      ensure => directory,
      purge   => true,
      force   => true,
      recurse => true;
    "${strongswan::config_dir}/hosts/__dummy__.conf":
      ensure  => 'present';
    '/etc/ipsec.conf':
      content => template('strongswan/ipsec.conf.erb');
  }

  service{'ipsec':
    ensure => running,
    enable => true,
  }

  if $strongswan::auto_remote_host and ($::strongswan_cert != 'false') and ($::strongswan_cert != '') {
    # export
    @@strongswan::remote_host{$::fqdn:
      right_cert_content  => $::strongswan_cert,
      right_ip_address    => $default_left_ip_address,
      tag                 => $::fqdn
    }
    #Strongswan::Remote_Host<<| tag == 'auto' and tag != $::fqdn |>>
    Strongswan::Remote_Host<<| tag != $::fqdn |>>
  }

}
