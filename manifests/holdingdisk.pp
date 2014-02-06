# == Define: amanda::holdingdisk
#
# Configuration section for a holdingdisk in Amanda
#
# === Parameters
#
# [*holdingdisk_name*]
#   (Namevar: If omitted, this parameter's value defaults to the resource title)
#
#   The name to use for this holdingdisk in the config file, if different from the
#   resource title.
#
# [*config*]
#   The name of the amanda configuration to add this holdingdisk to
#
# [*directory*]
#   The path to the holding area (on a local disk)
#
# [*use*]
#   Amount of space that can be used in the holding disk area.
#   If zero, all available space is used. If negative, that amount of space is left free.
#   Default is 0. You can used units; e.g. "10 gb"
#
# [*chunksize*]
#   Split temporary files into chunks of this size; useful mostly for filesystems that
#   have a max file size. 0 is effectively unlimited. Default is 1 gb.
#
# [*order*]
#   Where to put this section in the config file. Should be no reason to set this.
#   Default is $::amanda::params::holdingdisk_order
#
# === Examples
# 
#   amanda::holdingdisk { 'hold0':
#     config    => 'daily',
#     directory => '/var/spool/amanda',
#     use       => '100 gb',
#     chunksize => '0',
#   }
#
# === Authors
#
# Calvin Walton <calvin.walton@kepstin.ca>
#
# === Copyright
#
# Copyright 2014 Calvin Walton <calvin.walton@kepstin.ca>
#
define amanda::holdingdisk(
  $holdingdisk_name = $name,
  $config           = 'daily',
  $directory        = undef,
  $use              = undef,
  $chunksize        = undef,
  $order            = undef
) {
  include ::amanda::params
  include ::amanda::server

  validate_re($holdingdisk_name, $::amanda::params::name_re)
  validate_re($config, $::amanda::params::name_re)
  validate_absolute_path($directory)

  if ($order) {
    $real_order = $order
  } else {
    $real_order = $::amanda::params::holdingdisk_order
  }

  file { "amanda::holdingdisk::${name}":
    ensure => 'directory',
    path   => $directory,
    owner  => $::amanda::params::user,
    group  => $::amanda::params::group,
    mode   => '0770',
  }

  concat::fragment { "amanda::holdingdisk::${name}":
    target  => "${::amanda::params::configdir}/${config}/amanda.conf",
    content => template("amanda/amanda.conf/holdingdisk.erb"),
    order   => $real_order,
    require => File["amanda::holdingdisk::${name}"]
  }
}
