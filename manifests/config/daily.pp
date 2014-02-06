# == Class: amanda::config::daily
#
# Set up a complete, basic configuration for daily backup to a "virtual tape"
# disk. This is intended mostly as a reference, but is completely usable.
#
# There are two dumptypes predefined that you can use to set up directories
# to backup: 'local' (gnutar, fast compression, local auth) and 'remote'
# (gnutar, fast compression, ssh auth).
#
# === Parameters
#
# [*directory*]
#   Directory to use for virtual tape changer. Parent directory must exist.
#
# [*tape_length*]
#   A number used by Amanda for scheduling backups.
#
class amanda::config::daily (
  $directory       = '/srv/amanda',
  $tape_length     = '1 gb',
  $holdingdisk_use = '10 gb',
  $holdingdisk_dir = '/srv/amanda-daily-holdingdisk',
  $dumpcycle       = 10,
  $tapecycle       = 55,
  $runtapes        = 5,
) {
  amanda::config { 'daily':
    tapetype       => 'vtape',
    tpchanger      => 'vtape',
    autolabel_when => 'empty',
    dumpcycle      => $dumpcycle,
    tapecycle      => $tapecycle,
    runtapes       => $runtapes,
    cron_hour      => fqdn_rand(24),
    cron_minute    => fqdn_rand(60),
  }
  amanda::holdingdisk { 'daily':
    config    => 'daily',
    directory => $holdingdisk_dir,
    use       => $holdingdisk_use,
  }
  amanda::changer::disk { 'daily-vtape':
    config           => 'daily',
    changer_name     => 'vtape',
    directory        => $directory,
    num_slot         => $tapecycle,
    auto_create_slot => true,
  }
  amanda::tapetype { 'daily-vtape':
    config        => 'daily',
    tapetype_name => 'vtape',
    length        => $tape_length,
    filemark      => '4 kb',
  }
  Amanda::Dumptype {
    config => 'daily',
  }
  amanda::dumptype { 'daily-global':
    dumptype_name => 'global',
    index         => true,
    record        => true,
    program       => 'GNUTAR',
    inherit       => [ 'compress-fast' ],
  }
  amanda::dumptype { 'daily-local':
    dumptype_name => 'local',
    auth          => 'local',
    inherit       => [ 'global' ],
  }
  amanda::dumptype { 'daily-remote':
    dumptype_name => 'remote',
    auth          => 'ssh',
    inherit       => [ 'global' ],
  }
}
