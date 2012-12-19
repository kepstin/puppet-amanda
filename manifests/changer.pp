# == Define: amanda::changer
#
# Configuration section for a "tape" changer in Amanda
#
# === Parameters
#
# [*changer_name*]
#   (Namevar: If omitted, this parameter's value defaults to the resource title)
#   
#   The name to use for this changer in the config file, if different from the
#   resource title.
#
# [*tpchanger*]
#   The Amanda 'tpchanger' string defining the changer and device
#
# [*changerdev*]
#   An alternate device specification required by some changers
#
# [*changerfile*]
#   A state storage file required by some changers
#
# [*config*]
#   The name of the amanda configuration to add this changer to
#
# [*inherit*]
#   A list of changer to include in this one, inheriting properties. Note that
#   you can only inherit from changers defined previously in the file; use the
#   order parameter to set that.
#
# [*order*]
#   The position in the file to place the changer. If you're not using inherit,
#   you can leave this unset. Default is $::amanda::params::changer_order
#
# [*property*]
#   A list of key-value pairs to set changer properties. In order to set
#   multiple values, pass an array as the value.
#
# [*tapedev*]
#   Specifies the tape device for changers using the old syntax.
#
# === Examples
#
# Instead of using the amanda::changer type directly, you can also use the 
# 'changer' parameter on amanda::config. See its documentation for details.
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
define amanda::changer (
  $changer_name = $name,
  $tpchanger,
  $changerdev   = undef,
  $changerfile  = undef,
  $config       = 'daily',
  $inherit      = [],
  $order        = undef,
  $property     = {},
  $tapedev      = undef,
) {
  validate_re($changer_name, $::amanda::params::name_re)
  validate_re($config, $config_re)
  validate_hash($property)
  validate_array($inherit)

  include amanda::params
  include amanda::server

  if ($order) {
    $real_order = $order
  } else {
    $real_order = $::amanda::params::changer_order
  }

  concat::fragment { "amanda::changer::$name":
    target  => "${::amanda::server::configdir}/${config}/amanda.conf",
    content => template("amanda/amanda.conf/changer.erb"),
    order   => $real_order,
    require => Amanda::Config[$config],
  }
}
