# == Define: amanda::dle
#
# Configure a disklist entry for Amanda
#
# === Parameters
#
# [*diskname*]
#   The name of the disk (a label). Usually the path to be backed up.
#   This parameter is a namevar, it defaults to the resource name.
#
# [*dumptype*]
#   The name of the dumptype to use for this backup.
#
# [*config*]
#   Which Amanda configuration to add this dle to.
#
# [*diskdevice*]
#   The device or file path to back up. Defaults to $diskname. You usually only
#   need to set this if you have multiple disklist entries referring to the
#   same diskdevice (since the diskname has to be unique)
#
# [*hostname*]
#   The name of the host to be backed up.
#
# [*interface*]
#   The name of a network interface definition, used to balance network load.
#   You don't normally need to set this.
#
# [*spindle*]
#   A number used to balance backup load on a host. Amanda will not run
#   multiple backups at the same time on the same spindle. Default is no
#   restriction, you don't normally need to set this.
#
# === Examples
#
#   amanda::dle { 'daily-localhost-/etc':
#     config   => 'daily',
#     hostname => 'localhost',
#     diskname => '/etc',
#     dumptype => 'compress-fast',
#   }
#
# === Authors
#
# Calvin Walton <calvin.walton@kepstin.ca>
#
# === Copyright
#
# Copyright 2012 Calvin Walton <calvin.walton@kepstin.ca>
#
define amanda::dle (
  $diskname   = $name,
  $dumptype,
  $config     = 'daily',
  $diskdevice = undef,
  $hostname   = 'localhost',
  $interface  = 'local',
  $spindle    = -1,
) {
  include amanda::params
  include amanda::server

  validate_re($config, $::amanda::params::name_re)
  validate_re($dumptype, $::amanda::params::name_re)

  if $order {
    $real_order = $order
  } else {
    $real_order = $::amanda::params::dle_order
  }

  if $diskdevice {
    $real_diskdevice = $diskdevice
  } else {
    $real_diskdevice = $diskname
  }

  concat::fragment { "amanda::dle::${name}":
    target  => "${::amanda::params::configdir}/${config}/disklist",
    content => template('amanda/disklist/dle.erb'),
    order   => $real_order,
  }
}
