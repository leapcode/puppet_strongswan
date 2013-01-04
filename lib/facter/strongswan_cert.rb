Facter.add("strongswan_cert") do
  setcode do
    cert_path = "certs/#{Facter.value(:fqdn)}.asc"
    if d = ['/etc/ipsec.d','/etc/strongswan/ipsec.d'].find{|d| File.exists?(File.join(d,cert_path)) } 
      File.read(File.join(d,cert_path))
    else
      nil
    end
  end
end
