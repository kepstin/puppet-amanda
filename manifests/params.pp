# == Class: amanda::params
#
# General parameters for Amanda configuration that can usually be automatically
# determined.
class amanda::params (
  $override_client_package = undef,
  $override_group          = undef,
  $override_server_package = undef,
  $override_user           = undef,
) {

  case $::osfamily {
    'Debian': {
      # Package names
      $os_server_package = 'amanda-server'
      $os_client_package = 'amanda-client'

      # User and group
      $os_user  = 'backup'
      $os_group = 'backup'

      # File locations and paths
      $configdir = '/etc/amanda'
      $logdir = '/var/log/amanda'
      $vardir = '/var/lib/amanda'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily}")
    }
  }

  # Handle overrides
  if $override_server_package {
    $server_package = $override_server_package
  } else {
    $server_package = $os_server_package
  }
  if $override_client_package {
    $client_package = $override_client_package
  } else {
    $client_package = $os_client_package
  }
  if $override_user {
    $user = $override_user
  } else {
    $user = $os_user
  }
  if $override_group {
    $group = $override_group
  } else {
    $group = $os_group
  }

  $infofile = "${vardir}/curinfo"
  $indexdir = "${vardir}/index"

  # This are the allowed characters in a 'name' in the Amanda configuration
  $name_re = '^[a-zA-Z0-9_-]+$'

  # amanda.conf fragment ordering
  $header_order        = '000'
  $holdingdisk_order   = '010'
  $dumptype_order      = '020'
  $tapetype_order      = '030'
  $interface_order     = '040'
  $application_order   = '050'
  $script_order        = '060'
  $device_order        = '070'
  $changer_order       = '080'
  $interactivity_order = '090'
  $taperscan_order     = '100'
  $footer_order        = '999'
}
