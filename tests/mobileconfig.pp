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
