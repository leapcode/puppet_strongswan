class strongswan(
  $manage_shorewall = false,
  $monkeysphere_publish_key = false
) {

  class{'monkeysphere':
    publish_key => $monkeysphere_publish_key
  } -> class{'strongswan::base': }

  if $manage_shorewall {
    include shorewall::rules::ipsec
  }
}
