# manage a strongswan
class strongswan(
  $manage_shorewall = false,
  $monkeysphere_publish_key = false,
  $ipsec_nat = false
) {

  class{'monkeysphere':
    publish_key => $monkeysphere_publish_key
  } -> class{'certtool': }
  
  case $::operatingsystem {
    centos: {
      case $::lsbmajdistrelease {
        '5': {
          $config_dir = '/etc/ipsec.d'
          class{'strongswan::centos::five':
            require => Class['monkeysphere'],
          }
        }
        default: {
          $config_dir = '/etc/strongswan'
          class{'strongswan::centos::six':
            require => Class['monkeysphere'],
          }
        }
      }
    }
    default: {
      $config_dir = '/etc/ipsec.d'
      class{'strongswan::base':
        require => Class['monkeysphere'],
      }
    }
  }

  if $manage_shorewall {
    include shorewall::rules::ipsec
    if $ipsec_nat {
      include shorewall::rules::ipsec_nat
    }
  
  }
}
