class strongswan(
  $manage_shorewall = false
) {

  include strongswan::base

  if $manage_shorewall {
    include shorewall::rules::ipsec
  }
}
