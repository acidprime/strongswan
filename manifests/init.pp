# == Class: openswan
#
# Full description of class openswan here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { openswan:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2011 Your name here, unless otherwise noted.
#
class strongswan(
  $wan_ip,
  $primary_dns,
  $secondary_dns,
  $rightsourceip,
  $leftnexthop,
  $rightsubnet = '0.0.0.0/0',
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

  file {'/etc/strongswan/ipsec.secrets':
    ensure  => file,
    content => template("${module_name}/ipsec.secrets.erb"),
    notify  => Service['strongswan'],
  }

  file { '/etc/ipsec.secrets':
    ensure  => file,
    content => template("${module_name}/ipsec.secrets.erb"),
    notify  => Service['strongswan'],
  }

  file { '/etc/strongswan/ipsec.conf':
    ensure  => file,
    content => template("${module_name}/ipsec.conf.erb"),
    notify  => Service['strongswan'],
  }
  file { '/etc/ipsec.conf':
    ensure  => file,
    content => template("${module_name}/ipsec.conf.erb"),
    notify  => Service['strongswan'],
  }

}
