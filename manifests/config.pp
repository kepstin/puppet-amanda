# == Define: amanda::config
#
# Build a configuration for Amanda
#
# === Parameters
#
# [*changer*]
#   An array of tape changer configurations. The format is like that used by
#   create_resources, except that you can leave the 'config' parameter blank
#   (an example is below). You can leave this blank and call the
#   amanda::changer type directly if you prefer.
#   Note that the names you provide must be unique over all configs!
#
# === Examples
#
#   amanda::config { 'daily':
#     changer => {
#       'vtape0' => {
#         tpchanger => 'chg-disk:/amanda/vtape0',
#       },
#     },
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
define amanda::config (
  $changer      = {},
  $changer_disk = {},
  $dumpcycle    = undef,
  $org          = $name,
  $runspercycle = undef,
  $tapecycle    = undef,
  $tpchanger    = undef,
  $extra_config = {},
) {

  validate_hash($changer)
  validate_hash($changer_disk)

  include amanda::server
  include amanda::params

  $logdir = $::amanda::params::logdir
  $indexdir = $::amanda::params::indexdir
  $user = $::amanda::params::user

  file { "${::amanda::params::configdir}/${name}":
    ensure  => 'directory',
    owner   => $::amanda::params::user,
    group   => $::amanda::params::group,
    mode    => '0660',
    purge   => $::amanda::server::purge,
    recurse => true,
    force   => true,
  }

  $amanda_conf_target = "${::amanda::params::configdir}/${name}/amanda.conf"
  concat { $amanda_conf_target:
    owner => $::amanda::params::user,
    group => $::amanda::params::group,
    mode  => '0660',
  }

  concat::fragment { "amanda::config::${name}::amanda_conf_header":
    target  => $amanda_conf_target,
    content => template("amanda/amanda.conf/header.erb"),
    order   => $::amanda::params::header_order,
  }

  concat::fragment { "amanda::config::${name}::amanda_conf_footer":
    target  => $amanda_conf_target,
    content => template("amanda/amanda.conf/footer.erb"),
    order   => $::amanda::params::footer_order,
  }

  create_resources(amanda::changer, $changer, { config => $name })
  create_resources(amanda::changer::disk, $changer_disk, { config => $name })

  $disklist_target = "${::amanda::params::configdir}/${name}/disklist"
  concat { $disklist_target:
    owner => $::amanda::params::user,
    group => $::amanda::params::group,
    mode  => '0660',
  }

  concat::fragment { "amanda::config::${name}::disklist_header":
    target  => $disklist_target,
    content => template("amanda/disklist/header.erb"),
    order   => $::amanda::params::header_order,
  }
}
