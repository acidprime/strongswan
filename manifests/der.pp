# == Definition: strongswan::der
#
# Export a cert pair to DER format
#
# == Parameters
#   [*basedir*]   - directory where you want the export to be done. Must exists
#   [*cert*]      - PEM certificate
#
define strongswan::der(
  $basedir,
  $cert,
  $ensure = 'present',
) {
  case $ensure {
    'present': {

    $args_hash = {
      '-in'        => $cert,
      '-inform'    => 'PEM',
      '-outform'   => 'DER',
      '-out'       => "${basedir}/${name}.cer",
    }

    $args = shellquote(any2array($args_hash))

      exec {"Export ${name} to ${basedir}/${name}.cer":
        command => "openssl x509 $args",
        creates => "${basedir}/${name}.cer",
        path    => $::path,
      }
    }
    'absent': {
      file {"${basedir}/${name}.cer":
        ensure => absent,
      }
    }
  }
}
