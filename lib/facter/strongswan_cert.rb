Facter.add("strongswan_cert") do
  setcode do
      File.exists?( "/etc/ipsec.d/certs/#{Facter.value(:fqdn)}.asc" ) ? File.read( "/etc/ipsec.d/certs/#{Facter.value(:fqdn)}.asc" ) : false
  end
end
