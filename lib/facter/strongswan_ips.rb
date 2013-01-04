Facter.add("strongswan_ips") do
  setcode do
    result = nil
    if bin = ['/usr/sbin/ipsec', '/usr/sbin/strongswan'].find{|f| File.exists?(f) } 
      output = Facter::Util::Resolution.exec("#{bin} statusall | grep -E '^  [0-9a-f]'").to_s.split("\n").collect(&:strip)
      result = output.join(',') unless output.empty?
    end
    result
  end
end
