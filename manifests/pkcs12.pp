# == Definition: strongswan::pkcs12
#
# Export a key pair to PKCS12 format
#
# == Parameters
#   [*basedir*]   - directory where you want the export to be done. Must exists
#   [*pkey*]      - private key
#   [*cert*]      - certificate
#   [*pkey_pass*] - private key password
#
define strongswan::pkcs12(
  $basedir,
  $pkey,
  $cert,
  $pkey_pass,
  $ensure = 'present'
) {
  case $ensure {
    'present': {
      $pass_opt = $pkey_pass ? {
        ''      => '',
        default => "-passout pass:${pkey_pass}",
      }

      $args_hash = {
        '-in'     => $cert,
        '-inkey'  => $pkey,
        '-out'    => "${basedir}/${name}.p12",
        '-name'   => $name,
      }

      $args = shellquote(any2array($args_hash))

      exec {"Export ${name} to ${basedir}/${name}.p12":
        command => "openssl pkcs12 -export -nodes -noiter ${args} ${pass_opt}",
        creates => "${basedir}/${name}.p12",
        path    => $::path,
      }
    }
    'absent' : {
      file {"${basedir}/${name}.p12":
        ensure => absent,
      }
    }
  }
}
