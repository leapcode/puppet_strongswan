# strongswan on centos 5
class strongswan::centos::five inherits strongswan::base {
  if $::selinux == 'true' {
    package{'strongswan-selinux':
      ensure => installed,
      before => Service['ipsec'],
    }

    selinux::fcontext{
      '/var/run/charon.ctl':
        setype => 'ipsec_var_run_t';
    }
  }
}
