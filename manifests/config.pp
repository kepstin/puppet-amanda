# == Define: amanda::config
#
# Build a configuration for Amanda
#
# === Parameters
#
# [*config_name*]
#   (Namevar: If omitted, this parameter's value defaults to the resource title)
#
#   The name to use for the configuration; the configuration file path.
#
# [*autolabel_pattern*]
#   The filename pattern to use when autolabelling. Defaults to
#   "$c-%%%%%%%%". Setting this variable is not sufficient to enable
#   autolabelling, you must also set autolabel_when.
#
# [*autolabel_when*]
#   Set the conditions in which to autolabel tapes. Default is no autolabelling.
#   A good choice if you're using disk-based virtual tapes is "empty". You can
#   pass multiple values in an array.
#
# [*cron_hour*]
#   The hour at which the cron job will run. Default is midnight.
#
# [*cron_minute*]
#   The minute at which the cron job will run. Default is right on the hour.
#
# [*cron_monthday*]
#   The days of the month at which the cron job will run; default unset.
#
# [*cron_weekday*]
#   The weekday(s) at which the cron job will run; default unset.
#
# [*dumpcycle*]
#   The default value for the number of days in the backup cycle.
#
# [*labelstr*]
#   A regular expression that matches tape labels to use with this config.
#   The default is "${config_name}-[0-9][0-9]*" which matches the default
#   autolabel_pattern value. If you want all labels to match, set this to ".*"
#
# [*org*]
#   The 'org' name in the config file. Defaults to $config_name.
#
# [*runspercycle*]
#   The default value for the number of times amdump runs in $dumpcycle days.
#   Unless you're using a custom cron job, this should be equal to $dumpcycle,
#   which is the default.
#
# [*runtapes*]
#   The default value for the maximum number of tapes that Amanda can use on
#   each run.
#
# [*tapecycle*]
#   The default value for the number of active volumes that Amanda will keep
#   around before overwriting them. This must be greater than $runspercycle
#   times $runtapes.
#
# [*tapetype*]
#   The tapetype to use when otherwise unspecified. No default.
#
# [*tpchanger*]
#   A tape changer specification to use as a default tape changer. For really
#   simple configurations only, otherwise leave unset and use a tapetype.
#
# [*extra_config*]
#   A list of extra configuration lines to include in the header of the
#   amanda.conf file, for unusual configurations. You are responsible for all
#   required quoting, etc. Lines will be added in order, after the options
#   handled internally.
#
# === Examples
#
#   amanda::config { 'daily':
#     dumpcycle      => 14,
#     tapecycle      => 28,
#     tapetype       => 'mytape',
#     autolabel_when => 'empty',
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
  $config_name       = $name,
  $autolabel_pattern = '$c-%%%%%%%%',
  $autolabel_when    = undef,
  $cron_hour         = 0,
  $cron_minute       = 0,
  $cron_monthday     = undef,
  $cron_weekday      = undef,
  $dumpcycle         = 10,
  $labelstr          = undef,
  $org               = undef,
  $runspercycle      = 0,
  $runtapes          = 1,
  $tapecycle         = 15,
  $tapetype          = undef,
  $tpchanger         = undef,
  $extra_config      = [],
) {

  include amanda::server
  include amanda::params

  validate_re($config_name, $::amanda::params::config_name)

  if $org {
    $real_org = $org
  } else {
    $real_org = $config_name
  }
  validate_re($real_org, $::amanda::params::name_re)
  if $labelstr {
    $real_labelstr = $labelstr
  } else {
    $real_labelstr = "${config_name}-[0-9][0-9]*"
  }
  if $runspercycle and ($runspercycle > 0) { 
    $real_runspercycle = $runspercycle
  } else {
    $real_runspercycle = $dumpcycle
  }
  if $tapecycle <= ($real_runspercycle * $runtapes) {
    fail('tapecycle is set too low for the number of tapes that will be used')
  }
  validate_array($extra_config)

  $infofile = $::amanda::params::infofile
  $logdir = $::amanda::params::logdir
  $indexdir = $::amanda::params::indexdir
  $user = $::amanda::params::user

  file { "${::amanda::params::configdir}/${config_name}":
    ensure  => 'directory',
    owner   => $::amanda::params::user,
    group   => $::amanda::params::group,
    mode    => '0660',
    purge   => $::amanda::server::purge,
    recurse => true,
    force   => true,
  }

  $amanda_conf_target = "${::amanda::params::configdir}/${config_name}/amanda.conf"
  concat { $amanda_conf_target:
    owner => $::amanda::params::user,
    group => $::amanda::params::group,
    mode  => '0660',
  }

  concat::fragment { "amanda::config::${name}::amanda_conf_header":
    target  => $amanda_conf_target,
    content => template('amanda/amanda.conf/header.erb'),
    order   => $::amanda::params::header_order,
  }

  $disklist_target = "${::amanda::params::configdir}/${config_name}/disklist"
  concat { $disklist_target:
    owner => $::amanda::params::user,
    group => $::amanda::params::group,
    mode  => '0660',
  }

  concat::fragment { "amanda::config::${name}::disklist_header":
    target  => $disklist_target,
    content => template('amanda/disklist/header.erb'),
    order   => $::amanda::params::header_order,
  }

  # Run a configuration check to verify settings
  # Note that 'su' is used as a workaround to puppet not being able to capture
  # output from commands run as other users
  exec { "amanda::config::${name}::amcheck":
    path    => '/usr/bin:/usr/sbin:/bin:/sbin',
    unless  => "su ${::amanda::params::user} -c '${::amanda::params::amcheck} ${config_name}' >/dev/null",
    command => "su ${::amanda::params::user} -c '${::amanda::params::amcheck} ${config_name}'",
    require => [
      File[$amanda_conf_target],
      File[$disklist_target]
    ],
  }

  cron { "amanda::config::${name}":
    command  => "${::amanda::params::amdump} ${config_name}",
    user     => $::amanda::params::user,
    hour     => $cron_hour,
    minute   => $cron_minute,
    weekday  => $cron_weekday,
    monthday => $cron_monthday,
  }
}
