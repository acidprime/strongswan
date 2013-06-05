Strongswan::Mobileconfig{
  remote_address       => 'ice.wallcity.org',
  payload_identifier   => 'org.wallcity.vpn',
  payload_organization => 'wallcity',
}
strongswan::mobileconfig { 'zipad.wallcity.org' :
  x_auth_name => 'example',
  pkcs12_pass => 'FC0AE2BFC4EA',
  export_dir  =>'/tmp',
}
