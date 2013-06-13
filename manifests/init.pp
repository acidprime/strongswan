# == Class: strongswan
#
# Full description of class strongswan here.
#
# === Parameters
#
# Document parameters here.
#
# [*wan_ip*]
#   This should be the WAN IP fact , see smoke test for fact example
# [*primary_dns*]
#  The DNS Server passed to the VPN client
# [*secondary_dns*]
#  The DNS Server passed to the VPN client
# [*rightsourceip*]
#  CIDR notation of the VPN IP range
# [*leftnexthop*]
#  The gateway that should be used
# [*eap_auth / eap_secret*]
#  Beta feature enable eap if you have compiled eap support into strong swan
# [*rightsubnet*]
#  Leave open to 0.0.0.0/0 for WAN vpn access
#
# Author Name Zack Smith zack.smith@puppetlabs.com
#
# === Copyright
#
# Copyright 2011 Zack Smith, unless otherwise noted.
#
class strongswan(
  $wan_ip,
  $primary_dns,
  $secondary_dns,
  $rightsourceip,
  $leftnexthop,
  $erb_secrets = true,
  $eap_auth = false,
  $rightsubnet = '0.0.0.0/0',
  $eap_server = 'localhost',
  $eap_secret = '$changeMe',
){
  service { 'strongswan':
    ensure  => running,
    enable  => true,
    require => Package['strongswan'],
  }

  package { 'strongswan':
    ensure => present,
  }

  file {'/etc/strongswan/strongswan.conf':
    ensure     => file,
    content    => template("${module_name}/strongswan.conf.erb"),
    require    => Package['strongswan'],
    notify     => Service['strongswan'],
  }

  if $erb_secrets {
    file {'/etc/strongswan/ipsec.secrets':
      ensure  => file,
      content => template("${module_name}/ipsec.secrets.erb"),
      notify  => Service['strongswan'],
    }
  }

  file { '/etc/strongswan/ipsec.conf':
    ensure  => file,
    content => template("${module_name}/ipsec.conf.erb"),
    notify  => Service['strongswan'],
  }

}
