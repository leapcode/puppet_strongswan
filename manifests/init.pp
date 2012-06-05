class strongswan {

  include strongswan::base

  if hiera('use_shorewall',false) {
    include shorewall::rules::ipsec
  }
}
