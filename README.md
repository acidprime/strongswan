# StrongSwan Puppet Module
## IPSEC Configuration for VPN Clients (currently iOS clients, more config templates to come)

This module will setup a strong swan IPSEC server that can be used with any
IKEv2 compatible client. The intial release focuses on [iOS](http://wiki.strongswan.org/projects/strongswan/wiki/IOS_(Apple)) and its "Cisco" client and Centos 6.4. and Puppet Enterprise 2.8.1  

The following is an example configuration on Centos machine with two ethernet interfaces:  
```puppet
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
```

The class `strongswan::puppet` will automatically copy the puppet certificate authority and puppet agent cert to the string swan configuration.
This basically means that any puppet certificate is a valid certificate and thus puppet clients can resuse their agent cert for two factor authentication.  

When using this option, you can automatically build VPN mobileconfig files for iOS 

```puppet
Strongswan::Mobileconfig{
  remote_address       => 'vpn.yourcompany.com',
  payload_identifier   => 'com.yourcompany.vpn',
  payload_organization => 'yourcompany',
}

class {'strongswan::mobileconfig::setup':} ->


# Create the certificate automatically in puppet
# Export to the export_dir (hint: .htaccess web portal root or email script)
strongswan::mobileconfig { 'ipad.yourcompany.com' :
  x_auth_name => 'bob',
  pkcs12_pass => 'FC0SFFF2FFGBFC4EA',
  export_dir  =>'/tmp',
}
```
This can be automated using the [create_resources function](http://docs.puppetlabs.com/references/latest/function.html#createresources)
The concept of the export_dir would be either some kind of email script that emails the person thier configuration profile, or a web portal such as a simple apache configuration.
As this defined resource type generates puppet certificates, it must be run on the Puppet Certificate authority not the VPN server at the moment. Also be aware that if you are using 
Puppet Enterprise your licenses are tied to the number of ssl certificates you currently have configured.

I will be updating the module to make it more flexible and include multiple tested configurations for different clients.  

This module assume you have a server connected to both a WAN and LAN ethernet inetface.  

The following would be an example of the needed firewall configuration using the puppetlabs [firewall module](http://forge.puppetlabs.com/puppetlabs/firewall) and a [sysctl module](http://forge.puppetlabs.com/trlinkin/sysctl)

```puppet
  resources { 'firewall':
    purge => true
  }

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
    source => "${::network_eth1}/24",
  }
```

### Compling Strong Swan
Strong swan supports multiple plugins including eap,ldap and dhcp
The following is what this was compiled with (post package install):

```puppet
package { 'gmp-devel':
  ensure => present,
}
package { 'openldap-devel':
  ensure => present,
}
package { 'libcurl-devel':
  ensure => present,
}
package { 'openssl-devel':
  ensure => present,
}
```

The following configure options where used after installing the packages above:

```shell
./configure \
--prefix=/usr \
--sysconfdir=/etc \
--enable-charon \
--enable-curl \
--enable-ldap \
--enable-pkcs11 \
--enable-aes \
--enable-des \
--enable-sha1 \
--enable-sha2 \
--enable-md4 \
--enable-md5 \
--enable-random \
--enable-nonce \
--enable-x509 \
--enable-revocation \
--enable-constraints \
--enable-pubkey \
--enable-pkcs1 \
--enable-pkcs8 \
--enable-pgp \
--enable-dnskey \
--enable-pem \
--enable-openssl \
--enable-fips-prf \
--enable-gmp \
--enable-xcbc \
--enable-cmac \
--enable-hmac \
--enable-ccm \
--enable-gcm \
--enable-attr \
--enable-kernel-netlink \
--enable-resolve \
--enable-socket-default \
--enable-farp \
--enable-stroke \
--enable-updown \
--enable-eap-identity \
--enable-eap-aka \
--enable-eap-aka-3gpp2 \
--enable-eap-md5 \
--enable-eap-gtc \
--enable-eap-mschapv2 \
--enable-eap-dynamic \
--enable-eap-radius \
--enable-eap-tls \
--enable-eap-ttls \
--enable-eap-peap \
--enable-eap-tnc \
--enable-xauth-generic \
--enable-xauth-eap \
--enable-dhcp \
```

As EPEL was out of date I just used the module to install the testing copy and until it gets updated I just modifed the install after `make install`

```

Changed `/etc/init.d/strongswan` from the strongswan to ipsec from make install i.e. `exec="/usr/sbin/ipsec"`
