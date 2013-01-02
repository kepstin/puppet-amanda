# == Define: amanda::dumptype
#
# Configuration section for a dumptype in Amanda
#
# === Parameters
#
# [*dumptype_name*]
#   (Namevar: If omitted, this parameter's value defaults to the resource title)
#   
#   The name to use for this dumptype in the config file, if different from the
#   resource title.
#
# [*config*]
#   The name of the amanda configuration to add this dumptype to
#
# [*inherit*]
#   A list of dumptypes to include in this one, inheriting properties. Note that
#   you can only inherit from dumptypes defined previously in the file; use the
#   order parameter to set that.
#
# [*order*]
#   The position in the file to place the dumptype. If you're not using inherit,
#   you can leave this unset. Default is $::amanda::params::dumptype_order
#
# [*tapedev*]
#   Specifies the tape device for changers using the old syntax.
#
# === Examples
#
#   amanda::changer { 'vtape0':
#     tpchanger => 'chg-disk:/amanda/vtape0',
#     property  => {
#       num-slot         => 10,
#       auto-create-slot => 'yes',
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
define amanda::dumptype (
  $dumptype_name = $name,
  $config        = 'daily',
  $auth          = undef,
  $compress      = undef,
  $estimate      = undef,
  $index         = undef,
  $program       = undef,
  $record        = undef,
  $inherit       = undef,
  $order         = undef,
  $property      = {},
  $extra_config  = [],
) {
  include amanda::params
  include amanda::server

  validate_re($dumptype_name, $::amanda::params::name_re)
  validate_re($config, $::amanda::params::name_re)
  validate_hash($property)
  validate_array($inherit)
  validate_array($extra_config)
  if $estimate != undef {
    validate_array($estimate)
  }
  if $index != undef {
    validate_bool($index)
  }
  if ($program != undef) && (!($program in [ 'DUMP', 'GNUTAR', 'APPLICATION' ])) {
    fail("program must be one of DUMP, GNUTAR, or APPLICATION")
  }
  if $record != undef {
    validate_bool($record)
  }

  if $order {
    $real_order = $order
  } else {
    $real_order = $::amanda::params::dumptype_order
  }

  concat::fragment { "amanda::dumptype::${name}":
    target  => "${::amanda::params::configdir}/${config}/amanda.conf",
    content => template("amanda/amanda.conf/dumptype.erb"),
    order   => $real_order,
  }
}
