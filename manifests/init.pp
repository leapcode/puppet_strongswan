class strongswan {
  
  include strongswan::base
  
  if $use_shorewall {
    include shorewall::rules::ipsec  
    include shorewall::rules::out::ipsec  
  }
}
