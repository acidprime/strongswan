  class {'strongswan':
    primary_dns   => '4.2.2.4',
    secondary_dns => '4.2.2.2',
    wan_ip        => $::ipaddress_eth1,       #WAN IP
    rightsourceip => '192.168.34.210/24',     #VPN IP Range
    leftnexthop   => '1.2.3.4',               #WAN Router
    eap_server    => '192.168.34.249',        #EAP Server
    eap_secret    => '48DB-947B-245579EC14AE',#EAP Secret
  } ->
  class {'strongswan::puppet':}               #CA Support
