# == Define: amanda::changer::disk
#
# Helpful wrapper for amanda::changer for 'disk' changers that will manage
# directories for you
#
define amanda::changer::disk (
  $changer_name     = $name,
  $directory,
  $config,
  $auto_create_slot = false,
  $num_slot         = 0,
  $removable        = false,
  $mount            = false,
  $umount           = false,
  $umount_idle      = false,
) {

  include amanda::params

  validate_absolute_path($directory)
  validate_re($changer_name, $::amanda::params::name_re)

  $lockfilename = regsubst(regsubst($directory, '^/', ''), '/', '-', 'G')

  file { "amanda::changer::disk::${name}":
    ensure => 'directory',
    path   => $directory,
    owner  => $::amanda::params::user,
    group  => $::amanda::params::group,
    mode   => '0660',
  }

  amanda::changer { $name:
    changer_name => $changer_name,
    tpchanger    => "chg-disk:${directory}",
    config       => $config,
    property     => {
      'auto-create-slot': $auto_create_slot,
      'mount':            $mount,
      'num-slot':         $num_slot,
      'removable':        $removable,
      'umount':           $umount,
      'umount-lockfile':  "${vardir}/${lockfilename}-lock",
      'umount-idle':      $umount_idle,
    },
    require      => File["amanda::changer::disk::${name}"],
  }

}
