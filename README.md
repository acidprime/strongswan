# StrongSwan Puppet Module
## IPSEC Configuration for VPN Clients (currently iOS clients, more config templates to come)

This module will setup a strong swan IPSEC server that can be used with any
IKEv2 compatible client. The intial release focuses on [iOS](http://wiki.strongswan.org/projects/strongswan/wiki/IOS_(Apple)) and its "Cisco" client and Centos 6.4. and Puppet Enterprise 2.8.1  

Current Instructions:

* Download a 6.4 copy of [CentOS](http://isoredirect.centos.org/centos/6/isos/x86_64/)  
* Install and two network interfaces  
Here is an example of the `/etc/sysconfig/network-scripts/ifcfg-eth1` needed for the WAN interface:

```shell
DEVICE=eth1
HWADDR=00:98:E8:98:SC:95
TYPE=Ethernet
UUID=bcfec5bf-2dea-3611-823d-zadfakeb22a4
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=1.2.3.4
NETMASK=255.255.255.248
GATEWAY=1.2.3.1
DEFROUTE=yes
```
Configure `/etc/sysconfig/network-scripts/ifcfg-eth0` for your internal network (perhaps just through DHCP  

Download and install [Puppet Enterise](http://info.puppetlabs.com/download-pe.html)  
Ensure proper DNS and configure the Master and Console role, here is an example answer file `-a`:  
```shell
q_install=y
q_puppet_cloud_install=y
q_puppet_enterpriseconsole_auth_database_name=console_auth
q_puppet_enterpriseconsole_auth_database_password=djhafhkjhfkfhskjhf
q_puppet_enterpriseconsole_auth_database_user=console_auth
q_puppet_enterpriseconsole_auth_password=someadminpass
q_puppet_enterpriseconsole_auth_user_email=admin@yourcompany.com
q_puppet_enterpriseconsole_database_install=n
q_puppet_enterpriseconsole_database_name=console
q_puppet_enterpriseconsole_database_password=fdfsfdiaJ9iwBfsdffdsfsdf
q_puppet_enterpriseconsole_database_remote=n
q_puppet_enterpriseconsole_database_root_password=fsfdsfdsfsfG
q_puppet_enterpriseconsole_database_user=console
q_puppet_enterpriseconsole_httpd_port=443
q_puppet_enterpriseconsole_install=y
q_puppet_enterpriseconsole_inventory_hostname=puppet.yourcompany.com
q_puppet_enterpriseconsole_inventory_port=8140
q_puppet_enterpriseconsole_master_hostname=puppet.yourcompany.com
q_puppet_enterpriseconsole_setup_db=y
q_puppet_enterpriseconsole_smtp_host=mail.yourcompany.com
q_puppet_enterpriseconsole_smtp_password=
q_puppet_enterpriseconsole_smtp_port=25
q_puppet_enterpriseconsole_smtp_use_tls=n
q_puppet_enterpriseconsole_smtp_user_auth=n
q_puppet_enterpriseconsole_smtp_username=
q_puppet_symlinks_install=y
q_puppetagent_certname=puppet.yourcompany.com
q_puppetagent_install=y
q_puppetagent_server=puppet.yourcompany.com
q_puppetca_install=y
q_puppetmaster_certname=puppet.yourcompany.com
q_puppetmaster_dnsaltnames=puppet
q_puppetmaster_enterpriseconsole_hostname=localhost
q_puppetmaster_enterpriseconsole_port=443
q_puppetmaster_install=y
q_vendor_packages_install=y
q_verify_packages=y
```
You can have the puppet master and vpn server on different boxes, but the defined resource type
mentioned below for generating the mobile configuration must be ran on the puppet master (CA)  

The following is an example configuration on Centos machine with two ethernet interfaces:  
```puppet
  class {'strongswan':
    primary_dns   => '4.2.2.4',
    secondary_dns => '4.2.2.2',
    wan_ip        => $::ipaddress_eth1,       #WAN IP
    rightsourceip => '192.168.34.210/24',     #VPN IP Range
    leftnexthop   => '1.2.3.1',               #WAN Router
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
    iniface => 'eth1',
  }

  firewall { '2014 Accept FORWARD in':
    ensure   => 'present',
    action   => 'accept',
    iniface => 'eth1',
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
    outiface => 'eth1',
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
