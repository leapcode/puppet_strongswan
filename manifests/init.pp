# manage a strongswan
class strongswan(
  $manage_shorewall         = false,
  $shorewall_source         = 'net',
  $use_monkeysphere         = false,
  $monkeysphere_publish_key = false,
  $ipsec_nat                = false,
  $default_left_ip_address  = $::ipaddress,
  $default_left_subnet      = reject(split($::strongswan_ips,','),$::ipaddress),
  $additional_options       = '',
  $auto_remote_host         = false,
  $ipsec_conf_template      = 'strongswan/ipsec.conf.erb',
  $custom_hostname          = $::fqdn
) {

  if $use_monkeysphere != false {
    class { 'monkeysphere':
      publish_key => $monkeysphere_publish_key
    } -> class { 'certtool': }

    $require_monkeysphere = $use_monkeysphere ? {
      true  => Class['monkeysphere'],
      false => ''
    }
  }

  case $::operatingsystem {
    centos: {
      case $::lsbmajdistrelease {
        '5': {
          $config_dir = '/etc/ipsec.d'
          $cert_dir   = '/etc/ipsec.d'
          $binary     = '/usr/sbin/ipsec'

          class { 'strongswan::centos::five':
            require => $require_monkeysphere
          }
        }
        default: {
          $config_dir = '/etc/strongswan'
          $cert_dir   = '/etc/strongswan/ipsec.d'
          $binary     = '/usr/sbin/strongswan'
          class { 'strongswan::centos::six':
            require => $require_monkeysphere
          }
        }
      }
    }
    default: {
      $config_dir = '/etc/ipsec.d'
      $cert_dir   = '/etc/ipsec.d'
      $binary     = '/usr/sbin/ipsec'
      class { 'strongswan::base':
        require => $require_monkeysphere
      }
    }
  }

  if $auto_remote_host and ($::strongswan_cert != 'false') and ($::strongswan_cert != '') {
    # export myself
    @@strongswan::remote_host { $strongswan::custom_hostname:
      right_cert_content  => $::strongswan_cert,
      right_ip_address    => $strongswan::default_left_ip_address,
      right_subnet        => $strongswan::default_left_subnet,
      tag                 => 'strongswan_auto'
    }
    # collect all other auto exported
    # myself is excluded in the template
    Strongswan::Remote_Host<<| tag == 'strongswan_auto' |>>
  }

  if $manage_shorewall {
    shorewall::rules::ipsec {
      $strongswan::shorewall_source:
    }
    if $ipsec_nat {
      include shorewall::rules::ipsec_nat
    }
  }
}
