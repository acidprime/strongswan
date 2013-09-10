define strongswan::mobileconfig (
  $pkcs12_pass,
  $export_dir,
  $x_auth_name,
  $remote_address,
  $payload_identifier,
  $payload_organization,
  $device_name = $name,
  $payload_description = "${module_name} VPN configuration",
  $payload_display_name = "VPN (${remote_address})",
  $user_defined_name = $payload_display_name,
)
{

  validate_absolute_path($export_dir)
  validate_string($pkcs12_pass)
  validate_string($x_auth_name)
  validate_string($remote_address)
  validate_string($payload_identifier)
  validate_string($payload_description)
  validate_string($device_name)


  require strongswan::mobileconfig::setup

  puppet_certificate { $device_name :
    ensure        => present,
  }

  strongswan::pkcs12 { $device_name :
    ensure    => 'present',
    basedir   => $export_dir,
    pkey      => "${::settings::ssldir}/private_keys/${device_name}.pem",
    cert      => "${::settings::ssldir}/certs/${device_name}.pem",
    pkey_pass => $pkcs12_pass,
    require   => Puppet_certificate[$device_name],
  }

  $module_path = get_module_path($module_name)

  $args_hash = {
    '--username'     => $x_auth_name,
    '--description'  =>  $payload_description,
    '--identity'     => "${export_dir}/${device_name}.p12",
    '--identifier'   => $payload_identifier,
    '--password'     => $pkcs12_pass,
    '--remote'       => $remote_address,
    '--write'        => "${export_dir}/${device_name}.mobileconfig",
    '--organization' => $payload_organization,
    '--name'         => $user_defined_name
  }

  $args = shellquote(any2array($args_hash))

  exec { 'mc_generate':
    command   => "${module_path}/scripts/mc_generate.py ${args}",
    logoutput => on_failure,
    creates   => "${export_dir}/${device_name}.mobileconfig",
    require   => [ Strongswan::Der['ca'] , Strongswan::Pkcs12[$device_name]],
  }
}
