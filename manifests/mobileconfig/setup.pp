class strongswan::mobileconfig::setup(
  $export_dir = '/var/www/profiles',
) {
  package { 'python':
    ensure => present,
  }

  strongswan::der { 'ca' :
    ensure    => 'present',
    basedir   => $export_dir,
    cert      => "${::settings::ssldir}/certs/ca.pem",
  }

}
