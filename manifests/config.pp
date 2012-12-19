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
  $changers     = {},
  $dumpcycle    = undef,
  $org          = $name,
  $runspercycle = undef,
  $tapecycle    = undef,
  $tpchanger    = undef,
  $extra_config = {},
) {
  validate_hash($changer)

  include amanda::server

  $amanda_conf_target = "${::amanda::server::configdir}/${name}/amanda.conf"

  concat { $amanda_conf_target:
    owner   => $::amanda::server::user,
    group   => $::amanda::server::group,
    mode    => '0660',
    require => File[$::amanda::params::configdir],
  }

  concat::fragment { "amanda::config::$name::amanda_conf_header":
    target  => $amanda_conf_target,
    content => template("amanda/amanda.conf/header.erb"),
    order   => $::amanda::params::header_order,
  }

  concat::fragment { "amanda::config::$name::amanda_conf_footer":
    target  => $amanda_conf_target,
    content => template("amanda/amanda.conf/footer.erb"),
    order   => $::amanda::params::footer_order,
  }

  create_resources(amanda::changer, $changer, { config => $name })
}
