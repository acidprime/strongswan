This module is currently in development

Has some hardcoded information in it
Example Configuration:

```puppet
  class {'strongswan':
    primary_dns   => '192.168.53.60',
    secondary_dns => '192.168.53.70',
    wan_ip        => $::ipaddress_eth2,
  } ->
  class {'strongswan::puppet':}

  resources { 'firewall':
    purge => true
  }
```

```puppet
  sysctl { 'net.ipv4.ip_forward':
      ensure  => 'present',
        value => '1',
  }
  sysctl { 'net.ipv4.conf.all.accept_redirects':
      ensure  => 'present',
        value => '0',
  }
  sysctl { 'net.ipv4.conf.all.send_redirects':
      ensure  => 'present',
        value => '0',
  }
  firewall { '1000 L2TP IKE':
    ensure  => 'present',
    action => 'accept',
    chain   => 'INPUT',
    dport   => ['500'],
    proto   => 'udp',
  }
  firewall { '1001 L2TP NAT-T':
    ensure => 'present',
    action => 'accept',
    chain  => 'INPUT',
    dport  => ['4500'],
    proto  => 'udp',
  }
  firewall { '1002 L2TP Traffic':
    ensure => 'present',
    action => 'accept',
    chain  => 'INPUT',
    proto  => 'udp',
    dport  => ['1701'],
    table    => 'filter',

  }
    ensure => 'present',
                                                                                                                                             98,1          54%
  firewall { '1003 L2TP Traffic':
    ensure => 'present',
    action => 'accept',
    chain  => 'INPUT',
    proto  => 'tcp',
    dport  => ['1701'],

  }
  firewall { '1012 ESP Traffic':
    ensure => 'present',
    action => 'accept',
    chain  => 'INPUT',
    proto  => 'esp',
    iniface => 'eth2',
  }

  firewall { '2014 Accept FORWARD in':
    ensure   => 'present',
    action   => 'accept',
    iniface => 'eth0',
    chain    => 'FORWARD',
  }
   firewall { '2014 Accept FORWARD out':
    ensure   => 'present',
    action   => 'accept',
    outiface => 'eth0',
    chain    => 'FORWARD',
  }

 firewall { '1004 NAT Traffic':
    ensure   => 'present',
    outiface => 'eth2',
    chain    => 'POSTROUTING',
    table    => 'nat',
    jump     => 'MASQUERADE',
  }

  firewall { '1005 IP':
    ensure => 'present',
    action => 'accept',
    chain  => 'FORWARD',
    source => "${::network_eth0}/24",
  }
```
