# manifests/init.pp - module to manage strongswan/ipsec

class strongswan::base {

  require monkeysphere
  require certtool

  package{ 'strongswan' :
    ensure => installed,
  }

  exec{ 'ipsec_privatekey':
    command => "certtool --generate-privkey --bits 2048 --outfile /etc/ipsec.d/private/${fqdn}.pem",
    creates => "/etc/ipsec.d/private/${fqdn}.pem",
    require => Package['strongswan'],
  }

  exec{ 'ipsec_monkeysphere_cert' :
    require => Exec['ipsec_privatekey'],
    creates => "/etc/ipsec.d/certs/${fqdn}.asc",
    command => "monkeysphere-host import-key /etc/ipsec.d/private/${fqdn}.pem ike://${fqdn} && gpg --homedir /var/lib/monkeysphere/host -a --export =ike://${fqdn} > /etc/ipsec.d/certs/${fqdn}.asc"
  }

  file{ '/etc/ipsec.secrets' : 
    content => ": RSA ${fqdn}.pem\n",
    require => Package['strongswan'],
    owner => "root", group => 0, mode => "400",
    notify => Service['strongswan'],
  }

  if $strongswan_cert != "false" and $strongswan_cert != "" {
    @@file{ "/etc/ipsec.d/certs/${fqdn}.asc":
      owner => "root", group => 0, mode => "400",
      tag => 'strongswan_cert',
      content => $strongswan_cert,
      require => Package['strongswan'],
      notify => Service['strongswan'],
    }
  }  

  File<<| tag == 'strongswan_cert' |>>

  file{ '/etc/ipsec.config' :
    source => "puppet:///modules/site-strongswan/configs/${fqdn}",
    owner => "root", group => 0, mode => "400",
    require => Package['strongswan'],
    notify => Service['strongswan'],
  }

  service{ 'strongswan' :
    ensure => running,
    enable => true,
  }

}
